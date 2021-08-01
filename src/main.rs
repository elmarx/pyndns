use std::string::FromUtf8Error;

use base64::{decode, encode, DecodeError};
use http::{HeaderMap, HeaderValue};
use serde::Deserialize;
use std::net::SocketAddr;
use warp::filters;
use warp::filters::header::{headers_cloned, value};
use warp::{reject, Filter, Rejection};

pub mod soa;
mod zone;

type WebResult<T> = std::result::Result<T, Rejection>;

#[derive(Deserialize, Debug)]
struct QueryParameters {
    ipaddr: String,
    ip6addr: Option<String>,
}

pub fn with_basic_auth(
    user: String,
    password: String,
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
    let update = warp::path("update")
        .and(with_basic_auth("elmar".to_string(), "geheim".to_string()))
        .and(warp::query::<QueryParameters>())
        .map(|username, p| {
            println!("{:#?} {:#?}", username, p);
            "OK"
        });

    warp::serve(update)
        .run("[::]:3030".parse::<SocketAddr>().unwrap())
        .await;
}
