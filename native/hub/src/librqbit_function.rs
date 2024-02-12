use std::sync::{Arc, Mutex};
use std::time::Duration;
use librqbit::{AddTorrent, AddTorrentOptions, ManagedTorrentState, Session};
use once_cell::sync::OnceCell;
use prost::bytes::Buf;
use crate::bridge::api::{RustOperation, RustRequest, RustResponse, RustSignal};
use prost::Message;
use size_format::SizeFormatterBinary as SF;
use crate::bridge::send_rust_signal;
use crate::messages::librqbit_torrent::{CurrentTorrentDownloadInfo, NewSessionInfo, TorrentStartState};

static SESSION_INSTANCE: OnceCell<Arc<Session>> = OnceCell::new();

pub async fn load_session(directory_path: &str) -> anyhow::Result<()>{
    SESSION_INSTANCE.set(Session::new(directory_path.parse().unwrap()).await?);
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

            let add_torrent_info = AddTorrent::from_url(torrent_add_info.magnet_link.as_str());

            let mut add_torrent_option = AddTorrentOptions::default();
            add_torrent_option.output_folder = Some(torrent_add_info.output_folder);
            add_torrent_option.overwrite = true;

            let add_result = SESSION_INSTANCE.get().clone().unwrap().add_torrent(add_torrent_info, Some(add_torrent_option)).await;
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
            for (idx, torrent) in torrents {
                let handle = &torrent.stats();
                let live = handle.clone().live.as_ref().unwrap();
                let peer_stats = &live.snapshot.peer_stats;
                let stats = &live.snapshot;
                let speed = &live.download_speed.mbps;
                //let remaining = &live.time_remaining.as_ref().unwrap().to_string();
                let total = handle.total_bytes;
                let progress = handle.progress_bytes;
                let downloaded_pct = if progress == 0 {
                    100f64
                } else {
                    (progress as f64 / total as f64) * 100f64
                };
                crate::debug_print!(
                    "[{}]: {:.2}% ({:.2}), down speed {:.2} MiB/s, fetched {}, remaining {:.2} of {:.2}, uploaded {:.2}, peers: {{live: {}, connecting: {}, queued: {}, seen: {}}}",
                    idx,
                    downloaded_pct,
                    SF::new(progress),
                    speed,
                    SF::new(stats.fetched_bytes),
                    "?",
                    SF::new(total),
                    SF::new(stats.uploaded_bytes),
                    peer_stats.live,
                    peer_stats.connecting,
                    peer_stats.queued,
                    peer_stats.seen,
                );

                let torrent_state = TorrentState {
                    id: Some(idx as i64),
                    pourcent: Some(downloaded_pct),
                    progress: Some(SF::new(progress).to_string()),
                    remaining: Some("?".to_string()),
                    total: Some(SF::new(total).to_string()),
                    downspeed: Some(speed.clone()),
                    peers: Some(peer_stats.live as i64),
                    state: i32::from(TorrentStartState::Running),
                    name: Some(torrent.info.info.name.clone().unwrap().to_string()),
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