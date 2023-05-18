use crate::addresses::merge;
use crate::model::{RRSet, Record, Zone};
use crate::{internal_error, PowerDnsApiConfiguration};
use axum::extract::{Query, State};
use axum::http::StatusCode;
use reqwest::Client;
use serde::{Deserialize, Serialize};

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
            name: value.name.to_string(),
            r#type: value.r#type.to_string(),
            ttl: value.ttl,
            changetype: ChangeType::Replace,
            records: value.records.to_owned(),
        }
    }
}

#[derive(Serialize, Debug)]
pub struct PatchZone {
    pub rrsets: Vec<PatchRRSet>,
}

pub async fn update(
    State(cfg): State<PowerDnsApiConfiguration>,
    Query(params): Query<QueryParameters>,
) -> Result<String, (StatusCode, String)> {
    let client = Client::new();

    let net = params.ip6lanprefix;

    let resp = client
        .get(&*cfg.zone_api_endpoint)
        .header("X-API-Key", &*cfg.api_key)
        .send()
        .await
        .map_err(internal_error)?
        .error_for_status()
        .map_err(internal_error)?
        .json::<Zone>()
        .await
        .map_err(internal_error)?;

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
        .await
        .map_err(internal_error)?
        .error_for_status()
        .map_err(internal_error)?;

    Ok("OK".to_string())
}
