use axum::http::StatusCode;

pub mod addresses;
pub mod model;
pub mod update;

pub const BASIC_SECRET: &str = "secret";
pub const BASIC_USERNAME: &str = "elmar";
pub const X_API_KEY: &str = "secret";
pub const ZONE_ENDPOINT: &str =
    "http://localhost:8081/api/v1/servers/localhost/zones/dyn.example.com.";
pub const PORT: u16 = 3030;

/// Utility function for mapping any error into a `500 Internal Server Error`
/// response.
fn internal_error<E>(err: E) -> (StatusCode, String)
where
    E: std::error::Error,
{
    (StatusCode::INTERNAL_SERVER_ERROR, err.to_string())
}
