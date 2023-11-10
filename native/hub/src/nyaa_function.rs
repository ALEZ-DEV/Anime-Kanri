use std::error::Error;
use crate::bridge::api::{RustOperation, RustRequest, RustResponse, RustSignal};
use prost::Message;

use nyaa_rsearch::{models::categories, r#async as async_func, SearchInput};
use crate::messages::nyaa_search::{ReadRequest, ReadResponse, Torrent};

pub async fn handle_nyaa_search(rust_request: RustRequest) -> RustResponse {

    match rust_request.operation {
        RustOperation::Create => RustResponse::default(),
        RustOperation::Read => {
            crate::debug_print!("Getting torrents...");

            let message_byte = rust_request.message.unwrap();
            let request_message = ReadRequest::decode(message_byte.as_slice()).unwrap();

            let search_input = SearchInput::new(
                request_message.search_input,
                request_message.page_input,
                categories::Categories::Anime,
            ).unwrap();
            let search_result_r = async_func::search(search_input).await;

            match &search_result_r {
                Err(e) => {
                    crate::debug_print!("{}", format!("Something goes wrong : {}", e.to_string()));
                }
                Ok(_) => {
                    crate::debug_print!("Got torrents !");
                }
            }

            let search_result = search_result_r.unwrap();

            let torrents = search_result.torrents.iter().map(|t| {
                Torrent {
                    name: t.name.clone(),
                    torrent_file: t.torrent_file.clone(),
                    magnet_link: t.magnet_link.clone(),
                    size: t.magnet_link.clone(),
                    date: t.date.clone(),
                    seeders: t.seeders.clone(),
                    leechers: t.leechers.clone(),
                    approved: t.approved.clone(),
                }
            }).collect();

            let response_message = ReadResponse {
                search: search_result.search,
                current_page: search_result.current_page,
                page_max: search_result.page_max,
                torrents: torrents,
            };

            RustResponse {
                successful: true,
                message: Some(response_message.encode_to_vec()),
                blob: None,
            }
        },
        RustOperation::Update => RustResponse::default(),
        RustOperation::Delete => RustResponse::default(),
    }

}
