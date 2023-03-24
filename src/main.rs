use axum::{routing::get, Router};
use std::net::{Ipv6Addr, SocketAddr, SocketAddrV6};
use tower_http::auth::AddAuthorizationLayer;
use tower_http::trace::{DefaultMakeSpan, DefaultOnRequest, DefaultOnResponse, TraceLayer};
use tower_http::LatencyUnit;
use tracing::Level;

use dyndns::update::update;
use dyndns::{BASIC_SECRET, BASIC_USERNAME, PORT};

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let app = Router::new()
        .route("/update", get(update))
        .layer(AddAuthorizationLayer::basic(BASIC_USERNAME, BASIC_SECRET))
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
