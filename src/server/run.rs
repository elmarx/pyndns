use crate::pdns::Client;
use crate::server::state::AppState;
use crate::server::update::update;
use axum::Router;
use axum::routing::get;
use std::env::var;
use std::net::{Ipv6Addr, SocketAddrV6};
use tower_http::LatencyUnit;
use tower_http::trace::{DefaultMakeSpan, DefaultOnRequest, DefaultOnResponse, TraceLayer};
use tower_http::validate_request::ValidateRequestHeaderLayer;
use tracing::Level;

pub const PORT: u16 = 3030;

pub async fn run() -> std::io::Result<()> {
    let pdns_server_url =
        var("PDNS_SERVER_URL").expect("PDNS_SERVER_URL should be set to the API-URL of PowerDNS");
    let zone = var("DYNAMIC_ZONE").expect("Please set DYNAMIC_ZONE");

    let basic_username = var("BASIC_USERNAME").expect("Please set BASIC_USERNAME");
    let basic_secret = var("BASIC_SECRET").expect("Please set BASIC_SECRET");

    let client = Client::new(pdns_server_url, var("API_KEY").expect("Please set API_KEY"));

    // ValidateRequestHeaderLayer::basic is deprecated, but I plan to replace it anyway
    #[allow(deprecated)]
    let app = Router::new()
        .route("/update", get(update::<Client>))
        .with_state(AppState::new(client, zone))
        .layer(ValidateRequestHeaderLayer::basic(
            &basic_username,
            &basic_secret,
        ))
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

    let listener =
        tokio::net::TcpListener::bind(SocketAddrV6::new(Ipv6Addr::from(0u128), PORT, 0, 0))
            .await
            .unwrap();
    axum::serve(listener, app).await
}
