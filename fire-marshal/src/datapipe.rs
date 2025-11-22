use crate::api::state::AppState;
use anyhow::{anyhow, Context, Result};
use node_red_bridge::NodeRedMessage;
use pyro_core::pipeline::PipelineRecord;
use std::path::PathBuf;
use tokio::fs;
use tokio::time::{sleep, Duration};

const PROCESSED_DIR: &str = "processed";
const FAILED_DIR: &str = "failed";

pub fn spawn_pipeline_worker(state: AppState) -> tokio::task::JoinHandle<()> {
    tokio::spawn(async move {
        loop {
            if let Err(err) = process_queue(&state).await {
                eprintln!("[Fire Marshal] pipeline processing error: {err:?}");
            }
            sleep(state.pipeline_interval).await;
        }
    })
}

async fn process_queue(state: &AppState) -> Result<()> {
    let mut dir = match fs::read_dir(&state.pipeline_dir).await {
        Ok(dir) => dir,
        Err(err) => {
            if err.kind() == std::io::ErrorKind::NotFound {
                fs::create_dir_all(&state.pipeline_dir).await?;
                return Ok(());
            }
            return Err(err.into());
        }
    };

    while let Some(entry) = dir.next_entry().await? {
        let path = entry.path();
        if path.is_dir() {
            continue;
        }

        if let Err(err) = handle_pipeline_file(state, &path).await {
            eprintln!(
                "[Fire Marshal] Failed to handle pipeline {:?}: {err:?}",
                path
            );
            move_to_folder(&path, &state.pipeline_dir.join(FAILED_DIR)).await?;
        } else {
            move_to_folder(&path, &state.pipeline_dir.join(PROCESSED_DIR)).await?;
        }
    }

    Ok(())
}

async fn handle_pipeline_file(state: &AppState, path: &PathBuf) -> Result<()> {
    let bytes = fs::read(path)
        .await
        .with_context(|| format!("Failed to read pipeline file {:?}", path))?;
    let record: PipelineRecord = serde_json::from_slice(&bytes)
        .with_context(|| format!("Failed to parse pipeline file {:?}", path))?;

    let run_stats = {
        let mut orchestrator = state.orchestrator.write().await;
        let stats = orchestrator
            .create_pipeline(
                &record.id,
                &record.source,
                &record.destination,
                &record.payload,
            )
            .map_err(|e| anyhow!(e))?;
        let active_count = orchestrator.active_pipeline_count();
        drop(orchestrator);

        {
            let mut monitor = state.monitor.write().await;
            monitor.set_active_pipelines(active_count);
            monitor.increment_data((stats.nodes_count + stats.edges_count) as u64);
        }

        stats
    };

    let node_red = state.node_red.read().await;
    let message = NodeRedMessage::new(
        "fire-marshal/pipelines".to_string(),
        serde_json::json!({
            "event": "pipeline_processed",
            "pipeline_id": record.id,
            "source": record.source,
            "destination": record.destination,
            "nodes": run_stats.nodes_count,
            "edges": run_stats.edges_count,
            "processed_at": run_stats.processed_at,
        }),
    );
    let _ = node_red.send(message).await;

    Ok(())
}

async fn move_to_folder(path: &PathBuf, folder: &PathBuf) -> Result<()> {
    fs::create_dir_all(folder)
        .await
        .with_context(|| format!("Failed to create {:?}", folder))?;

    let file_name = path
        .file_name()
        .ok_or_else(|| anyhow!("Invalid pipeline file name {:?}", path))?;
    let target = folder.join(file_name);
    fs::rename(path, &target)
        .await
        .with_context(|| format!("Failed to move {:?} -> {:?}", path, target))?;

    Ok(())
}


