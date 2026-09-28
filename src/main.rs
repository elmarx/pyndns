mod addresses;
mod pdns;
mod server;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .init();

    server::run().await.expect("Server failed to run");
}
