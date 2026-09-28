pub mod addresses;
pub mod model;
pub mod update;

pub const PORT: u16 = 3030;

#[derive(Clone, Debug)]
pub struct PowerDnsApiConfiguration {
    pub api_key: String,
    pub zone_api_endpoint: String,
}
