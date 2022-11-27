use std::fs::File;
use std::io::Write;
use std::net::SocketAddr;
use std::process::Command;
use std::time::SystemTime;

use http::HeaderValue;
use ipnet::Ipv6Net;
use serde::Deserialize;
use warp::filters::header::value;
use warp::{reject, Filter, Rejection};

use hosts::HOSTS;

use crate::hosts::Host;

mod hosts;

pub fn zone_file(serial: &str) -> String {
    format!(
        r#"
$TTL 10m
$ORIGIN dyn.athmer.org.

@       IN      SOA     ns.inwx.de.        hostmaster  (
        {serial} ; serial
        1h        ; refresh
        15m       ; retry
        2w        ; expire
        5m        ; negative ttl
)

@           IN    NS       ns.inwx.de.
            IN    NS       ns2.inwx.de.
            IN    NS       ns3.inwx.eu.

terrance IN A 65.21.186.136
"#,
    )
}

type WebResult<T> = std::result::Result<T, Rejection>;

#[derive(Deserialize, Debug)]
pub struct QueryParameters {
    pub ipaddr: String,
    pub ip6addr: Option<String>,
    pub dualstack: Option<String>,
    pub ip6lanprefix: String,
}

pub fn with_basic_auth(
    _user: String,
    _password: String,
) -> impl Filter<Extract = ((String, String),), Error = Rejection> + Clone {
    value(http::header::AUTHORIZATION.as_str()).and_then(|auth_header: HeaderValue| async move {
        match auth_header.to_str() {
            Ok(auth_header) => {
                let username_password = auth_header.strip_prefix("Basic ");
                match username_password {
                    None => Err(reject()),
                    Some(user) => match base64::decode(user) {
                        Ok(user_password) => match String::from_utf8(user_password) {
                            Ok(user_password) => match user_password.split_once(":") {
                                None => Err(reject()),
                                Some((username, password)) => {
                                    Ok((username.to_string(), password.to_string()))
                                }
                            },
                            Err(_) => Err(reject()),
                        },
                        Err(_) => Err(reject()),
                    },
                }
            }
            Err(_) => Err(reject()),
        }
    })
}

fn generate_zone_file(hosts: &[Host], net: &Ipv6Net, main_addr: &str) -> String {
    let now = SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .unwrap();
    let mut zone_file = zone_file(now.as_secs().to_string().as_str());

    zone_file.push_str(format!("@ IN AAAA {}\n", main_addr).as_str());

    for x in hosts.iter() {
        zone_file.push_str(x.quad_a(net).as_str());
        zone_file.push('\n');
    }

    zone_file
}

fn write_zone_file(file: &str, s: &str) -> std::io::Result<()> {
    let mut file = File::create(file)?;
    file.write_all(s.as_bytes())
}

fn reload() -> std::io::Result<()> {
    Command::new("sudo")
        .arg("pdns_control")
        .arg("reload")
        .spawn()?
        .wait()?;

    Ok(())
}

#[tokio::main]
async fn main() {
    pretty_env_logger::init();
    let log = warp::log("dyndns");

    let zone_file = std::env::var("DYN_ATHMER_ZONE_FILE").expect("please set DYN_ATHMER_ZONE_FILE");

    let update = warp::path("update")
        .and(with_basic_auth("elmar".to_string(), "geheim".to_string()))
        .and(warp::query::<QueryParameters>())
        .map(move |_username, p: QueryParameters| {
            let net: Ipv6Net = p.ip6lanprefix.parse().unwrap();
            let zone_file_content = generate_zone_file(&HOSTS, &net, p.ipaddr.as_str());
            write_zone_file(&*zone_file, &*zone_file_content).expect("writing pdns zone file");
            reload().expect("reloading pdns zones");

            "OK"
        })
        .with(log);

    warp::serve(update)
        .run("[::]:3030".parse::<SocketAddr>().unwrap())
        .await;
}
