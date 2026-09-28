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

#[derive(Serialize, Debug)]
pub struct PatchRRSet {
    pub(crate) name: String,
    pub(crate) r#type: String,
    pub(crate) ttl: u32,
    pub(crate) changetype: ChangeType,
    pub(crate) records: Vec<Record>,
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

#[derive(Serialize, Debug)]
#[serde(rename_all = "UPPERCASE")]
pub enum ChangeType {
    Replace,
    _Delete,
}