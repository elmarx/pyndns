use crate::PowerDnsApiConfiguration;
use crate::addresses::merge;
use crate::model::{RRSet, Record, Zone};
use axum::extract::{Query, State};
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum_extra::TypedHeader;
use axum_extra::headers::Authorization;
use axum_extra::headers::authorization::Basic;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use tracing::info;

#[derive(Deserialize, Debug)]
pub struct QueryParameters {
    pub ipaddr: Option<String>,
    pub ip6addr: Option<String>,
    pub dualstack: Option<String>,
    pub ip6lanprefix: String,
}

#[derive(Serialize, Debug)]
#[serde(rename_all = "UPPERCASE")]
enum ChangeType {
    Replace,
    _Delete,
}

#[derive(Serialize, Debug)]
pub struct PatchRRSet {
    name: String,
    r#type: String,
    ttl: u32,
    changetype: ChangeType,
    records: Vec<Record>,
}

impl From<&RRSet> for PatchRRSet {
    fn from(value: &RRSet) -> Self {
        PatchRRSet {
            name: value.name.clone(),
            r#type: value.r#type.clone(),
            ttl: value.ttl,
            changetype: ChangeType::Replace,
            records: value.records.clone(),
        }
    }
}

#[derive(Serialize, Debug)]
pub struct PatchZone {
    pub rrsets: Vec<PatchRRSet>,
}

#[derive(thiserror::Error, Debug)]
pub enum Error {
    #[error("Failed to send request to powerdns: {0}")]
    RequestError(#[from] reqwest::Error),

    #[error("Failed to merge IPv6 address and prefix: {0}")]
    AddrMergeError(#[from] crate::addresses::AddrMergeError),
}

impl IntoResponse for Error {
    fn into_response(self) -> Response {
        (StatusCode::INTERNAL_SERVER_ERROR, self.to_string()).into_response()
    }
}

///
///
/// # Errors
///
/// returns an error if
/// - the request to the PowerDNS-API fails
/// - the IPv6 address and prefix are invalid
pub async fn update(
    State(cfg): State<PowerDnsApiConfiguration>,
    Query(params): Query<QueryParameters>,
    TypedHeader(authorization): TypedHeader<Authorization<Basic>>,
) -> Result<String, Error> {
    info!("Request from {}", authorization.username());

    let client = Client::new();

    let net = params.ip6lanprefix;

    let resp = client
        .get(&*cfg.zone_api_endpoint)
        .header("X-API-Key", &*cfg.api_key)
        .send()
        .await?
        .error_for_status()?
        .json::<Zone>()
        .await?;

    let rrsets = resp.rrsets.iter().filter_map(|rrset| {
        if rrset.r#type == "AAAA" {
            Some(PatchRRSet {
                records: rrset
                    .records
                    .iter()
                    .map(|r| Record {
                        disabled: r.disabled,
                        content: merge(r.content.as_str(), net.as_str()).unwrap().to_string(),
                    })
                    .collect(),
                r#type: rrset.r#type.clone(),
                changetype: ChangeType::Replace,
                name: rrset.name.clone(),
                ttl: rrset.ttl,
            })
        } else if rrset.r#type == "SOA" {
            None
        } else {
            Some(rrset.into())
        }
    });

    let payload = PatchZone {
        rrsets: rrsets.collect(),
    };

    let _resp = client
        .patch(&*cfg.zone_api_endpoint)
        .json(&payload)
        .header("X-API-Key", &*cfg.api_key)
        .send()
        .await?
        .error_for_status()?;

    Ok("OK".to_string())
}
