#[derive(Clone)]
pub struct AppState<C> {
    pub client: C,
    pub zone: String,
}

impl<C> AppState<C> {
    pub fn new(client: C, zone: String) -> Self {
        Self { client, zone }
    }
}
