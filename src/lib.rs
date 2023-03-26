use axum::http::StatusCode;

pub mod addresses;
pub mod model;
pub mod update;

pub const PORT: u16 = 3030;

#[derive(Clone, Debug)]
pub struct PowerDnsApiConfiguration {
    pub api_key: String,
    pub zone_api_endpoint: String,
}

/// Utility function for mapping any error into a `500 Internal Server Error`
/// response.
fn internal_error<E>(err: E) -> (StatusCode, String)
where
    E: std::error::Error,
{
    (StatusCode::INTERNAL_SERVER_ERROR, err.to_string())
}
