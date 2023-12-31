use std::sync::{Arc, Mutex};
use std::time::Duration;
use librqbit::session::{ManagedTorrentState, Session};
use librqbit::spawn_utils::BlockingSpawner;
use once_cell::sync::OnceCell;
use crate::bridge::api::{RustOperation, RustRequest, RustResponse, RustSignal};
use prost::Message;
use size_format::SizeFormatterBinary as SF;
use crate::bridge::send_rust_signal;
use crate::messages::librqbit_torrent::{CurrentTorrentDownloadInfo, NewSessionInfo, TorrentStartState};

static SESSION_INSTANCE: OnceCell<Arc<Session>> = OnceCell::new();

pub async fn load_session(directory_path: &str) -> anyhow::Result<()>{
    SESSION_INSTANCE.set(Arc::new(Session::new(directory_path.parse().unwrap(), BlockingSpawner::new(false)).await?));
    Ok(())
}

pub async fn manage_torrent(rust_request: RustRequest) -> RustResponse {
    use crate::messages::librqbit_torrent::{TorrentAddedInfo, TorrentAddInfo, NewSessionInfo};

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
                Err(e) =>  {
                    crate::debug_print!("Failed to add torrent : {}", e);
                    TorrentAddedInfo {
                        has_been_added: false,
                    }
                }
            };

            RustResponse {
                successful: true,
                message: Some(torrent_info.encode_to_vec()),
                blob: None,
            }
        }
        RustOperation::Update => {
            crate::debug_print!("Try to load the new session");

            let message_byte = rust_request.message.unwrap();
            let new_session_info = NewSessionInfo::decode(message_byte.as_slice()).unwrap();

            let result = load_session(new_session_info.directory_path.as_str()).await;

            match result {
                Ok(_) => RustResponse {
                    successful: true,
                    message: None,
                    blob: None,
                },
                Err(_) => RustResponse {
                    successful: true,
                    message: None,
                    blob: None,
                }
            }
        },
        RustOperation::Delete => RustResponse::default(),
    }
}

pub async fn update_torrents_status() {
    use crate::messages::librqbit_torrent::{TorrentState, ID, TorrentStartState, CurrentTorrentDownloadInfo};

    loop {
        crate::sleep(Duration::from_secs(1)).await;

        let mut current_torrent_download_info = Arc::new(Mutex::new(CurrentTorrentDownloadInfo {
            torrents_state: vec![],
        }));

        SESSION_INSTANCE.get().unwrap().with_torrents(|torrents| {
            for (idx, torrent) in torrents.iter().enumerate() {
                let torrent_state = match &torrent.state {
                    ManagedTorrentState::Initializing => {
                        crate::debug_print!("{} initializing", idx);

                        TorrentState {
                            id: None,
                            pourcent: None,
                            progress: None,
                            remaining: None,
                            total: None,
                            downspeed: None,
                            peers: None,
                            state: i32::from(TorrentStartState::Initializing),
                            name: None,
                        }
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

                        TorrentState {
                            id: Some(idx as i64),
                            pourcent: Some(downloaded_pct),
                            progress: Some(SF::new(progress).to_string()),
                            remaining: Some(SF::new(stats.remaining_bytes).to_string()),
                            total: Some(SF::new(total).to_string()),
                            downspeed: Some(speed.download_mbps()),
                            peers: Some(i64::from_be_bytes(peer_stats.live.to_be_bytes())),
                            state: i32::from(TorrentStartState::Running),
                            name: Some(handle.torrent_state().info().name.clone().unwrap().to_string()),
                        }
                    }
                };
                current_torrent_download_info.clone().lock().unwrap().torrents_state.push(torrent_state);
            }

            let signal = RustSignal {
                resource: ID,
                message: Some(current_torrent_download_info.lock().unwrap().encode_to_vec()),
                blob: None,
            };

            send_rust_signal(signal);
        })
    }
}