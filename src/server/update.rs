use crate::addresses;
use crate::pdns::{ApiClient, ChangeType, Error, PatchRRSet, PatchZone, Record};
use crate::server::state::AppState;
use axum::extract::{Query, State};
use axum_extra::TypedHeader;
use axum_extra::headers::Authorization;
use axum_extra::headers::authorization::Basic;
use ipnet::Ipv6Net;
use serde::Deserialize;
use std::collections::BTreeMap;
use tracing::info;

#[derive(Deserialize, Debug)]
pub struct DynDnsQueryParameters {
    #[allow(dead_code)]
    pub ipaddr: Option<String>,
    #[allow(dead_code)]
    pub ip6addr: Option<String>,
    #[allow(dead_code)]
    pub dualstack: Option<String>,
    #[allow(dead_code)]
    pub domainname: Option<String>,
    pub ip6lanprefix: Ipv6Net,

    #[allow(dead_code)]
    #[serde(flatten)]
    pub additional: BTreeMap<String, String>,
}

///
///
/// # Errors
///
/// returns an error if
/// - the request to the PowerDNS-API fails
/// - the IPv6 address and prefix are invalid
///
/// # Panics
///
/// If powerdns returns a non-parseable IPv6 address in the AAAA record.
pub async fn update<C: ApiClient>(
    State(AppState { client, zone }): State<AppState<C>>,
    Query(dyndns_params): Query<DynDnsQueryParameters>,
    TypedHeader(authorization): TypedHeader<Authorization<Basic>>,
) -> Result<String, Error> {
    info!("Request from {}", authorization.username());

    tracing::debug!("Received dyndns query parameters: {:?}", dyndns_params);

    let resp = client.get_zone(&zone).await?;

    let rrsets = resp.rrsets.iter().filter_map(|rrset| {
        if rrset.r#type == "AAAA" {
            Some(PatchRRSet {
                records: rrset
                    .records
                    .iter()
                    .map(|r| {
                        let address = r
                            .content
                            .parse()
                            .expect("powerdns to only return IPv6 addresses in AAAA records");

                        Record {
                            disabled: r.disabled,
                            content: addresses::merge(address, dyndns_params.ip6lanprefix)
                                .to_string(),
                        }
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

    client.patch_zone(&zone, &payload).await?;

    Ok("OK".to_string())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::pdns::{RRSet, Zone, ZoneKind};
    use std::sync::{
        Arc,
        atomic::{AtomicBool, Ordering},
    };

    #[derive(Clone)]
    struct MockClient {
        zone: Zone,
        patched: Arc<AtomicBool>,
    }

    impl ApiClient for MockClient {
        #[allow(clippy::unused_async_trait_impl)]
        async fn get_zone(&self, zone: &str) -> Result<Zone, Error> {
            assert_eq!(zone, "example");
            Ok(self.zone.clone())
        }

        #[allow(clippy::unused_async_trait_impl)]
        async fn patch_zone(&self, zone: &str, payload: &PatchZone) -> Result<(), Error> {
            assert_eq!(zone, "example");
            assert_eq!(payload.rrsets.len(), 2);
            let aaaa = &payload.rrsets[0];
            assert_eq!(aaaa.name, "host.example.");
            assert_eq!(aaaa.r#type, "AAAA");
            assert_eq!(aaaa.records[0].content, "2001:db8:2::1");
            assert!(matches!(aaaa.changetype, ChangeType::Replace));
            let a = &payload.rrsets[1];
            assert_eq!(a.r#type, "A");
            assert_eq!(a.records[0].content, "192.0.2.1");
            self.patched.store(true, Ordering::SeqCst);
            Ok(())
        }
    }

    #[tokio::test]
    async fn update_uses_client_to_patch_zone() {
        let record = |content: &str| Record {
            content: content.to_string(),
            disabled: false,
        };
        let rrset = |kind: &str, content: &str| RRSet {
            name: "host.example.".to_string(),
            r#type: kind.to_string(),
            ttl: 300,
            records: vec![record(content)],
        };
        let patched = Arc::new(AtomicBool::new(false));
        let client = MockClient {
            zone: Zone {
                id: "example.".to_string(),
                name: "example.".to_string(),
                url: "/api/v1/servers/localhost/zones/example.".to_string(),
                kind: ZoneKind::Native,
                rrsets: vec![
                    rrset("AAAA", "2001:db8:1::1"),
                    rrset("SOA", "ignored"),
                    rrset("A", "192.0.2.1"),
                ],
            },
            patched: patched.clone(),
        };
        let params = DynDnsQueryParameters {
            ipaddr: None,
            ip6addr: None,
            dualstack: None,
            domainname: None,
            ip6lanprefix: "2001:db8:2::/64".parse().unwrap(),
            additional: BTreeMap::new(),
        };

        let result = update(
            State(AppState {
                client,
                zone: "example".to_string(),
            }),
            Query(params),
            TypedHeader(Authorization::basic("user", "password")),
        )
        .await
        .unwrap();

        assert_eq!(result, "OK");
        assert!(patched.load(Ordering::SeqCst));
    }
}
