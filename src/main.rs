use crate::hosts::Host;
use hosts::HOSTS;
use http::HeaderValue;
use ipnet::Ipv6Net;
use serde::Deserialize;
use std::net::SocketAddr;
use std::time::SystemTime;
use warp::filters::header::value;
use warp::{reject, Filter, Rejection};

mod hosts;
mod zone;

pub fn zone_file(serial: &str) -> String {
    format!(
        r#"
$TTL 10m
$ORIGIN dyn.athmer.org.

@       IN      SOA     ns.inwx.de.        hostmaster  (
        {} ; serial
        1h        ; refresh
        15m       ; retry
        2w        ; expire
        5m        ; negative ttl
)

@           IN    NS       ns.inwx.de.
            IN    NS       ns2.inwx.de.
            IN    NS       ns3.inwx.eu.

"#,
        serial
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

fn generate_zone_file(hosts: &[Host], net: &Ipv6Net) -> String {
    let now = SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .unwrap();
    let mut zone_file = zone_file(now.as_secs().to_string().as_str());

    for x in hosts.iter() {
        zone_file.push_str(x.quad_a(net).as_str());
        zone_file.push('\n');
    }

    zone_file
}

#[tokio::main]
async fn main() {
    pretty_env_logger::init();
    let log = warp::log("dyndns");

    let update = warp::path("update")
        .and(with_basic_auth("elmar".to_string(), "geheim".to_string()))
        .and(warp::query::<QueryParameters>())
        .map(|_username, p: QueryParameters| {
            let net: Ipv6Net = p.ip6lanprefix.parse().unwrap();
            generate_zone_file(&HOSTS, &net)
        })
        .with(log);

    warp::serve(update)
        .run("[::]:3030".parse::<SocketAddr>().unwrap())
        .await;
}
