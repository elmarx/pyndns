use dyndns::model::Zone;
use reqwest::Client;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new();

    let resp = client
        .get("http://localhost:8081/api/v1/servers/localhost/zones/dyn.example.com.")
        .header("X-API-Key", "secret")
        .send()
        .await?
        .json::<Zone>()
        .await?;

    println!("{resp:#?}");
    Ok(())
}
