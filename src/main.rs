use http::HeaderValue;
use ipnet::Ipv6Net;
use serde::Deserialize;
use std::net::SocketAddr;
use warp::filters::header::value;
use warp::{reject, Filter, Rejection};

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

#[tokio::main]
async fn main() {
    pretty_env_logger::init();
    let log = warp::log("dyndns");

    let update = warp::path("update")
        .and(with_basic_auth("elmar".to_string(), "geheim".to_string()))
        .and(warp::query::<QueryParameters>())
        .map(move |_username, p: QueryParameters| {
            let net: Ipv6Net = p.ip6lanprefix.parse().unwrap();

            dbg!(net);
            "OK"
        })
        .with(log);

    warp::serve(update)
        .run("[::]:3030".parse::<SocketAddr>().unwrap())
        .await;
}
