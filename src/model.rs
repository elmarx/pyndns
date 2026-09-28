use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Deserialize)]
pub struct Zone {
    pub id: String,
    pub name: String,
    pub url: String,
    pub kind: ZoneKind,
    pub rrsets: Vec<RRSet>,
}

#[derive(Debug, Clone, PartialEq, Deserialize)]
pub enum ZoneKind {
    Native,
    Master,
    Slave,
}

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct RRSet {
    pub name: String,
    pub r#type: String,
    pub ttl: u32,
    pub records: Vec<Record>,
}

/// The `RREntry` object represents a single record.
#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct Record {
    pub content: String,
    pub disabled: bool,
}
