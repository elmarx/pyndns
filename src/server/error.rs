use crate::pdns::Error;
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};

impl IntoResponse for Error {
    fn into_response(self) -> Response {
        (StatusCode::INTERNAL_SERVER_ERROR, self.to_string()).into_response()
    }
}
