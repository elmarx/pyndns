use serde::Deserialize;
use std::net::{Ipv4Addr, Ipv6Addr};

#[derive(Deserialize, Debug)]
pub struct Zone {
    pub name: String,
    pub records: Vec<Record>,
}

#[derive(Deserialize, Debug)]
#[serde(tag = "type")]
pub enum Record {
    #[serde(rename = "AAAA")]
    Aaaa {
        content: Ipv6Addr,
        prio: i32,
        ttl: i32,
    },
    #[serde(rename = "A")]
    A {
        content: Ipv4Addr,
        prio: i32,
        ttl: i32,
    },
    #[serde(rename = "SOA")]
    Soa {
        content: String,
        prio: i32,
        ttl: i32,
    },
}

#[cfg(test)]
mod test {
    use crate::zone::Zone;
    use std::fs::File;
    use std::io::BufReader;

    #[test]
    pub fn test_read() {
        let file = File::open("./samples/redacted.zone.json").unwrap();
        let reader = BufReader::new(file);

        let zone: Result<Zone, _> = serde_json::from_reader(reader);
        let zone = zone.unwrap();

        assert_eq!(zone.records.len(), 8);
    }
}
