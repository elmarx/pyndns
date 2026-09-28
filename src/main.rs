use tracing::level_filters;

mod addresses;
mod pdns;
mod secrets_from_env;
mod server;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::builder()
                .with_default_directive(level_filters::LevelFilter::INFO.into())
                .from_env_lossy(),
        )
        .init();

    server::run().await.expect("Server failed to run");
}
