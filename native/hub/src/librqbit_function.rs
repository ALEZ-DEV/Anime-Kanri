use std::sync::Arc;
use std::time::Duration;
use librqbit::session::{AddTorrentResponse, ManagedTorrentState, Session};
use librqbit::spawn_utils::BlockingSpawner;
use once_cell::sync::OnceCell;
use crate::bridge::api::{RustOperation, RustRequest, RustResponse, RustSignal};
use prost::Message;
use size_format::SizeFormatterBinary as SF;
use crate::messages::nyaa_search::ReadResponse;


static SESSION_INSTANCE: OnceCell<Arc<Session>> = OnceCell::new();

pub async fn load_session(directory_path: &str) -> anyhow::Result<()>{
    SESSION_INSTANCE.set(Arc::new(Session::new(directory_path.parse().unwrap(), BlockingSpawner::new(false)).await?));
    Ok(())
}

pub async fn add_torrent(rust_request: RustRequest) -> RustResponse {
    use crate::messages::librqbit_torrent::{TorrentAddedInfo, TorrentAddInfo};

    match rust_request.operation {
        RustOperation::Create => RustResponse::default(),
        RustOperation::Read => {
            crate::debug_print!("Try to add torrent");

            let message_byte = rust_request.message.unwrap();
            let torrent_add_info = TorrentAddInfo::decode(message_byte.as_slice()).unwrap();

            let add_result = SESSION_INSTANCE.get().clone().unwrap().add_torrent(torrent_add_info.magnet_link.as_str(), None).await;
            let torrent_info = match add_result {
                Ok(_) => TorrentAddedInfo {
                    has_been_added: true,
                },
                Err(_) => TorrentAddedInfo {
                    has_been_added: false,
                }
            };

            RustResponse {
                successful: true,
                message: Some(torrent_info.encode_to_vec()),
                blob: None,
            }
        }
        RustOperation::Update => RustResponse::default(),
        RustOperation::Delete => RustResponse::default(),
    }
}

pub async fn update_torrents_status() {
    loop {
        crate::sleep(Duration::from_secs(1)).await;

        SESSION_INSTANCE.get().unwrap().with_torrents(|torrents| {
            for (idx, torrent) in torrents.iter().enumerate() {
                match &torrent.state {
                    ManagedTorrentState::Initializing => {
                        crate::debug_print!("{} initializing", idx);
                    }
                    ManagedTorrentState::Running(handle) => {
                        let peer_stats = handle.torrent_state().peer_stats_snapshot();
                        let stats = handle.torrent_state().stats_snapshot();
                        let speed = handle.speed_estimator();
                        let total = stats.total_bytes;
                        let progress = stats.total_bytes - stats.remaining_bytes;
                        let downloaded_pct = if stats.remaining_bytes == 0 {
                            100f64
                        } else {
                            (progress as f64 / total as f64) * 100f64
                        };
                        crate::debug_print!(
                            "[{}]: {:.2}% ({:.2}), down speed {:.2} MiB/s, fetched {}, remaining {:.2} of {:.2}, uploaded {:.2}, peers: {{live: {}, connecting: {}, queued: {}, seen: {}}}",
                            idx,
                            downloaded_pct,
                            SF::new(progress),
                            speed.download_mbps(),
                            SF::new(stats.fetched_bytes),
                            SF::new(stats.remaining_bytes),
                            SF::new(total),
                            SF::new(stats.uploaded_bytes),
                            peer_stats.live,
                            peer_stats.connecting,
                            peer_stats.queued,
                            peer_stats.seen,
                        );
                    }
                }
            }
        })
    }
}