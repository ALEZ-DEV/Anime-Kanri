use bridge::respond_to_dart;
use web_alias::*;
use with_request::handle_request;

mod bridge;
mod messages;
mod sample_functions;
mod web_alias;
mod with_request;
mod nyaa_function;

/// This `hub` crate is the entry point for the Rust logic.
/// Always use non-blocking async functions such as `tokio::fs::File::open`.
async fn main() {
    // This is `tokio::sync::mpsc::Reciver` that receives the requests from Dart.
    let mut request_receiver = bridge::get_request_receiver();
    // Repeat `crate::spawn` anywhere in your code
    // if more concurrent tasks are needed.
    while let Some(request_unique) = request_receiver.recv().await {
        crate::spawn(async {
            let response_unique = handle_request(request_unique).await;
            respond_to_dart(response_unique);
        });
    }
}
