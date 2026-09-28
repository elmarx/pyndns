use std::env;
use std::{fs, io};

#[derive(thiserror::Error, Debug)]
pub enum Error {
    #[error("failed to read secret from the file specified by `{variable}_FILE`")]
    File {
        variable: String,
        #[source]
        source: io::Error,
    },
    #[error("failed to read environment variable `{variable}`")]
    Environment {
        variable: String,
        #[source]
        source: env::VarError,
    },
}

pub fn secret_from_env(variable: &str) -> Result<String, Error> {
    let file_variable = format!("{variable}_FILE");
    if let Ok(path) = env::var(file_variable) {
        return fs::read_to_string(path)
            .map(|secret| secret.trim_end_matches(['\r', '\n']).to_owned())
            .map_err(|source| Error::File {
                variable: variable.to_owned(),
                source,
            });
    }

    env::var(variable).map_err(|source| Error::Environment {
        variable: variable.to_owned(),
        source,
    })
}
