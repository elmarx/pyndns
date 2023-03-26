use axum::{routing::get, Router};
use dyndns::update::update;
use dyndns::PowerDnsApiConfiguration;
use std::env::var;
use std::net::{Ipv6Addr, SocketAddr, SocketAddrV6};
use tower_http::auth::AddAuthorizationLayer;
use tower_http::trace::{DefaultMakeSpan, DefaultOnRequest, DefaultOnResponse, TraceLayer};
use tower_http::LatencyUnit;
use tracing::Level;

pub const PORT: u16 = 3030;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt().with_max_level(Level::INFO).init();

    let api_endpoint = var("API_ENDPOINT").unwrap();
    let zone = var("DYNAMIC_ZONE").unwrap();

    let basic_username = var("BASIC_USERNAME").unwrap();
    let basic_secret = var("BASIC_SECRET").unwrap();

    let cfg = PowerDnsApiConfiguration {
        api_key: var("API_KEY").unwrap(),
        zone_api_endpoint: format!("{}/api/v1/servers/localhost/zones/{}.", api_endpoint, zone),
    };

    let app = Router::new()
        .route("/update", get(update))
        .with_state(cfg)
        .layer(AddAuthorizationLayer::basic(&basic_username, &basic_secret))
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

    axum::Server::bind(&SocketAddr::V6(SocketAddrV6::new(
        Ipv6Addr::from(0u128),
        PORT,
        0,
        0,
    )))
    .serve(app.into_make_service())
    .await
    .unwrap();
}
