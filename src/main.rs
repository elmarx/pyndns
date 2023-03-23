use axum::extract::Query;
use axum::http::StatusCode;
use axum::{routing::get, Router};
use ipnet::Ipv6Net;
use serde::Deserialize;
use tower_http::auth::RequireAuthorizationLayer;
use tower_http::trace::{DefaultMakeSpan, DefaultOnRequest, DefaultOnResponse, TraceLayer};
use tower_http::LatencyUnit;
use tracing::Level;

#[derive(Deserialize, Debug)]
pub struct QueryParameters {
    pub ipaddr: String,
    pub ip6addr: Option<String>,
    pub dualstack: Option<String>,
    pub ip6lanprefix: String,
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let app = Router::new()
        .route("/update", get(handler))
        .layer(RequireAuthorizationLayer::basic("elmar", "secret"))
        .layer(
            TraceLayer::new_for_http()
                .make_span_with(DefaultMakeSpan::new().include_headers(true))
                .on_request(DefaultOnRequest::new().level(Level::INFO))
                .on_response(
                    DefaultOnResponse::new()
                        .level(Level::INFO)
                        .latency_unit(LatencyUnit::Micros),
                ),
        );

    axum::Server::bind(&"0.0.0.0:3030".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}

async fn handler(Query(params): Query<QueryParameters>) -> Result<String, (StatusCode, String)> {
    let net: Ipv6Net = params.ip6lanprefix.parse().unwrap();

    let mut prefix = net.network().to_string();
    prefix.pop();

    Ok(format!("Prefix {prefix}"))
}

/// Utility function for mapping any error into a `500 Internal Server Error`
/// response.
fn internal_error<E>(err: E) -> (StatusCode, String)
where
    E: std::error::Error,
{
    (StatusCode::INTERNAL_SERVER_ERROR, err.to_string())
}
