#[derive(Clone, Debug)]
pub struct PowerDnsApiConfiguration {
    pub api_key: String,
    pub zone_api_endpoint: String,
}

pub const PORT: u16 = 3030;