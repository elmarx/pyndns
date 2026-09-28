# run all local CI checks: compile check, tests, formatting, and lints
ci:
    cargo check --locked
    cargo nextest run
    cargo fmt -- --check
    cargo clippy --all-features --all-targets -- -D warnings
    cargo clippy --all-features --all-targets -- -W clippy::pedantic
