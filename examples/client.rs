use reqwest::Client;
use serde_json::Value;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new();

    let resp = client
        .get("http://localhost:8081/api/v1/servers/localhost/zones")
        .header("X-API-Key", "secret")
        .send()
        .await?
        .json::<Vec<Value>>()
        .await?;

    println!("{:#?}", resp);
    Ok(())
}
