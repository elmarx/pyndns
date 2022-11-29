use std::net::SocketAddr;

use axum::extract::Query;
use axum::routing::get;
use axum::Router;
use ipnet::Ipv6Net;
use serde::Deserialize;
use tower_http::auth::RequireAuthorizationLayer;
use tower_http::trace::{DefaultMakeSpan, DefaultOnRequest, DefaultOnResponse, TraceLayer};
use tower_http::LatencyUnit;
use tracing::Level;
use tracing_subscriber::layer::SubscriberExt;
use tracing_subscriber::util::SubscriberInitExt;

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

    axum::Server::bind(&"0.0.0.0:3030".parse().unwrap())
        .serve(app().into_make_service())
        .await
        .unwrap();
}

fn app() -> Router {
    Router::new()
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
        )
}

async fn handler(Query(params): Query<QueryParameters>) -> String {
    format!("{:?}", params)
}
