use axum::extract::{FromRef, FromRequestParts, Query};
use axum::http::request::Parts;
use axum::http::StatusCode;
use axum::{async_trait, routing::get, Router};
use bb8::{Pool, PooledConnection};
use bb8_postgres::PostgresConnectionManager;
use ipnet::Ipv6Net;
use serde::Deserialize;
use tokio_postgres::NoTls;
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

    // set up connection pool
    let manager = PostgresConnectionManager::new_from_stringlike(
        "host=localhost user=pdns password=pdns",
        NoTls,
    )
    .unwrap();
    let pool = Pool::builder()
        .min_idle(Some(0))
        .build(manager)
        .await
        .unwrap();

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
        )
        .with_state(pool);

    axum::Server::bind(&"0.0.0.0:3030".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}

async fn handler(
    DatabaseConnection(conn): DatabaseConnection,
    Query(params): Query<QueryParameters>,
) -> Result<String, (StatusCode, String)> {
    let net: Ipv6Net = params.ip6lanprefix.parse().unwrap();

    let mut prefix = net.network().to_string();
    prefix.pop();

    let rows = conn
        .execute(
            "UPDATE records SET content = regexp_replace(content, '([0-9a-f]{1,4}:){4}', $1::TEXT) where domain_id = (SELECT id from domains d WHERE d.name = 'dyn.example.com') and type = 'AAAA';",
            &[&prefix],
        )
        .await
        .map_err(internal_error)?;

    Ok(format!("Changed {rows} records"))
}

type ConnectionPool = Pool<PostgresConnectionManager<NoTls>>;

// we can also write a custom extractor that grabs a connection from the pool
// which setup is appropriate depends on your application
struct DatabaseConnection(PooledConnection<'static, PostgresConnectionManager<NoTls>>);

#[async_trait]
impl<S> FromRequestParts<S> for DatabaseConnection
where
    ConnectionPool: FromRef<S>,
    S: Send + Sync,
{
    type Rejection = (StatusCode, String);

    async fn from_request_parts(_parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let pool = ConnectionPool::from_ref(state);

        let conn = pool.get_owned().await.map_err(internal_error)?;

        Ok(Self(conn))
    }
}

/// Utility function for mapping any error into a `500 Internal Server Error`
/// response.
fn internal_error<E>(err: E) -> (StatusCode, String)
where
    E: std::error::Error,
{
    (StatusCode::INTERNAL_SERVER_ERROR, err.to_string())
}
