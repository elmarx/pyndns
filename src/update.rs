use crate::addresses::merge;
use crate::model::{RRSet, Record, Zone};
use crate::{internal_error, X_API_KEY, ZONE_ENDPOINT};
use axum::extract::Query;
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
enum ChangeType {
    REPLACE,
    DELETE,
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
            changetype: ChangeType::REPLACE,
            records: value.records.to_owned(),
        }
    }
}

#[derive(Serialize, Debug)]
pub struct PatchZone {
    pub rrsets: Vec<PatchRRSet>,
}

pub async fn update(Query(params): Query<QueryParameters>) -> Result<String, (StatusCode, String)> {
    let client = Client::new();

    let net = params.ip6lanprefix;

    let resp = client
        .get(ZONE_ENDPOINT)
        .header("X-API-Key", "secret")
        .send()
        .await
        .map_err(internal_error)?
        .json::<Zone>()
        .await
        .map_err(internal_error)?;

    let rrsets = resp.rrsets.iter().map(|rrset| {
        if rrset.r#type.as_str() == "AAAA" {
            PatchRRSet {
                records: rrset
                    .records
                    .iter()
                    .map(|r| Record {
                        disabled: r.disabled,
                        content: merge(r.content.as_str(), net.as_str()).unwrap().to_string(),
                    })
                    .collect(),
                r#type: rrset.r#type.clone(),
                changetype: ChangeType::REPLACE,
                name: rrset.name.clone(),
                ttl: rrset.ttl,
            }
        } else {
            rrset.into()
        }
    });

    let payload = PatchZone {
        rrsets: rrsets.collect(),
    };

    let _resp = client
        .patch(ZONE_ENDPOINT)
        .json(&payload)
        .header("X-API-Key", X_API_KEY)
        .send()
        .await
        .map_err(internal_error);

    Ok("OK".to_string())
}
