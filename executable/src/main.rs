use anyhow::Context;
use clap::Parser;
use copy_dir::copy_dir;
use crossterm::event::{Event, KeyCode};
use crossterm::style::Stylize;
use crossterm::{event, terminal};
use futures_util::StreamExt;
use once_cell::sync::Lazy;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use std::fs;
use std::fs::create_dir_all;
use std::io::Cursor;
use std::path::{Path, PathBuf};
use std::process::{exit, Command};
use std::time::Duration;

static CLIENT: Lazy<Client> = Lazy::new(|| {
    reqwest::ClientBuilder::new()
        .default_headers({
            let mut headers = reqwest::header::HeaderMap::new();
            headers.insert(
                reqwest::header::USER_AGENT,
                reqwest::header::HeaderValue::from_static("NatroMacro"),
            );
            headers
        })
        .build()
        .unwrap()
});

#[derive(Parser, Debug)]
struct Cli {
    #[arg(long, short, default_value = "0")]
    delay: u32,
}

struct ReleaseData {
    tag_name: String,
    zip: Asset,
    exe: Option<Asset>,
}

fn pause(message: &str) -> anyhow::Result<()> {
    // Setup terminal
    terminal::enable_raw_mode()?;

    println!("{}", message);

    // Wait for any key press
    loop {
        if event::poll(Duration::from_secs(0))? {
            if let Event::Key(_) = event::read()? {
                break;
            }
        }
    }

    // Restore terminal to previous state
    terminal::disable_raw_mode()?;
    Ok(())
}

fn accept_decline(message: &str, accept: KeyCode, decline: KeyCode) -> anyhow::Result<bool> {
    // Setup terminal
    terminal::enable_raw_mode()?;

    println!("{}\n", message);

    // Wait for any key press
    loop {
        if event::poll(Duration::from_secs(0))? {
            if let Event::Key(k) = event::read()? {
                if k.code == accept {
                    terminal::disable_raw_mode()?;
                    return Ok(true);
                } else if k.code == decline {
                    terminal::disable_raw_mode()?;
                    return Ok(false);
                } else {
                    println!("{}", "Invalid option".red())
                }
            }
        }
    }
}

#[tokio::main]
async fn main() {
    let res = cli().await;
    if res.is_err() {
        println!("{} {}", "Error:".red(), res.err().unwrap());
        pause("Press any key to exit").unwrap();
        exit(1);
    }
    res.expect("Should be able to run cli");
}

async fn cli() -> anyhow::Result<()> {
    let cli = Cli::parse();
    let cd = std::env::current_dir()?;
    let submacros = cd.join("submacros");
    let natro_macro = submacros.join("natro_macro.ahk");
    let ahk32 = submacros.join("AutoHotkeyU32.exe");

    let release_data = get_latest().await?;
    let latest = release_data.tag_name;

    if latest != env!("CARGO_PKG_VERSION") {
        println!(
            "{} {} {} {}",
            "A new version of Natro Macro is available! \n Current:\n".yellow(),
            env!("CARGO_PKG_VERSION").yellow(),
            "Latest:\n".yellow(),
            latest.clone().yellow()
        );
        let accepted = accept_decline(
            "Would you like to update? (y/n)",
            KeyCode::Char('y'),
            KeyCode::Char('n'),
        )
        .unwrap();

        if accepted {
            println!("Downloading Natro Macro {}...", latest);
            let zip_bytes = download(release_data.zip.clone()).await?;
            let update_path = cd.join(".update");
            create_dir_all(&update_path)?;
            let settings = &cd.join("settings");
            let update_settings = &update_path.join("settings");
            if settings.exists() {
                copy_dir(settings, update_settings)?;
            }
            let patterns = &cd.join("patterns");
            let update_patterns = &update_path.join("patterns");
            if patterns.exists() {
                copy_dir(patterns, update_patterns)?;
            }
            let paths = &cd.join("paths");
            let update_paths = &update_path.join("paths");
            if paths.exists() {
                copy_dir(paths, update_paths)?;
            }
            zip_extract::extract(Cursor::new(zip_bytes), &cd, true)?;

            if update_settings.exists() {
                fs::remove_dir_all(settings)?;
                copy_dir(update_settings, settings)?;
            }
            if update_patterns.exists() {
                fs::remove_dir_all(patterns)?;
                copy_dir(update_patterns, patterns)?;
            }
            if update_paths.exists() {
                fs::remove_dir_all(paths)?;
                copy_dir(update_paths, paths)?;
            }

            fs::remove_dir_all(update_path)?;

            if let Some(exe) = release_data.exe {
                println!("Downloading NatroMacro Starter {}...", latest);
                let exe_bytes = download(exe).await?;
                let exe_path = cd.join("new_natro.exe");
                fs::write(&exe_path, exe_bytes)?;
                let exe_os_str = exe_path.into_os_string();
                let exe_os = exe_os_str.to_string_lossy();
                //Waits 5 seconds copies the new exe over the old one, deletes the old one, starts the new one, and then deletes itself
                fs::write(cd.join("update.bat"), format!(
                    "Powershell.exe -Command  \"timeout /t 5 /nobreak; xcopy /y \\\"{}\\\" \\\"{}\\\"; del \\\"{}\\\"; start \\\"{}\\\"; (goto) 2>nul & del \"%~f0\"\";",
                    &exe_os,
                    std::env::current_exe()?.to_string_lossy(),
                    exe_os,
                    std::env::current_exe()?.to_string_lossy()
                ))?;
                Command::new("update.bat").spawn()?;
            }
            exit(0);
        }
    }

    if natro_macro.exists() && ahk32.exists() {
        let mut ahk_cmd = Command::new(&ahk32);
        ahk_cmd.arg(natro_macro);
        if cli.delay != 0 {
            println!("Starting natro macro in {} seconds", &cli.delay);
            tokio::time::sleep(Duration::from_secs(cli.delay as u64)).await;
        }
        let cmd_res = ahk_cmd.spawn();
        if cmd_res.is_err() {
            println!(
                "{} {}",
                "Failed to start Natro Macro:".red(),
                cmd_res.err().unwrap()
            );
            pause("Press any key to exit")?;
            return Ok(());
        }
        cmd_res?;
        exit(0);
    }

    if !ahk32.exists() {
        println!(
            "{}{:?} \n {}",
            "Could not find submacros\\AutoHotkeyU32.exe!
            This is most likely due to a third-party antivirus deleting the file:
            1. Disable any third-party antivirus software (or add the Natro Macro folder as an exception)
            2. Re-extract the macro and check that AutoHotkeyU32.exe exists in the 'submacros' folder
            3. Run ".red(),
            std::env::current_exe()?.file_name().context("Should be able to get name")?.to_string_lossy().red(),
            "Note: Both Natro Macro and AutoHotkey are safe and work fine with Microsoft Defender!
            Join our Discord server for support: discord.gg/natromacro".red()
        );
        pause("Press any key to exit")?;
        return Ok(());
    }

    let grandparent = get_grandparent(&cd);
    if grandparent.is_some() {
        //TODO: Check if the grandparent is a zip file
    }

    println!(
        "Unable to automatically extract Natro Macro!
- If you have already extracted, you are missing important files, please re-extract.
- If you have not extracted, you may have to manually extract the zipped folder.
Join our Discord server for support: discord.gg/natromacro
"
    );
    pause("Press any key to exit")?;
    Ok(())
}

#[derive(Serialize, Deserialize)]
pub struct ReleaseResponse {
    pub(crate) url: Option<String>,
    pub(crate) html_url: Option<String>,
    pub(crate) assets_url: Option<String>,
    pub(crate) upload_url: Option<String>,
    pub(crate) tarball_url: Option<String>,
    pub(crate) zipball_url: Option<String>,
    pub(crate) discussion_url: Option<String>,
    pub(crate) id: Option<i64>,
    pub(crate) node_id: Option<String>,
    pub(crate) tag_name: Option<String>,
    pub(crate) target_commitish: Option<String>,
    pub(crate) name: Option<String>,
    pub(crate) body: Option<String>,
    pub(crate) draft: Option<bool>,
    pub(crate) prerelease: Option<bool>,
    pub(crate) created_at: Option<String>,
    pub(crate) published_at: Option<String>,
    pub(crate) author: Option<Author>,
    pub(crate) assets: Option<Vec<Asset>>,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct Asset {
    pub(crate) url: Option<String>,
    pub(crate) browser_download_url: Option<String>,
    pub(crate) id: Option<i64>,
    pub(crate) node_id: Option<String>,
    pub(crate) name: Option<String>,
    pub(crate) label: Option<String>,
    pub(crate) state: Option<String>,
    pub(crate) content_type: Option<String>,
    pub(crate) size: Option<i64>,
    pub(crate) download_count: Option<i64>,
    pub(crate) created_at: Option<String>,
    pub(crate) updated_at: Option<String>,
    pub(crate) uploader: Option<Author>,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct Author {
    pub(crate) login: Option<String>,
    pub(crate) id: Option<i64>,
    pub(crate) node_id: Option<String>,
    pub(crate) avatar_url: Option<String>,
    pub(crate) gravatar_id: Option<String>,
    pub(crate) url: Option<String>,
    pub(crate) html_url: Option<String>,
    pub(crate) followers_url: Option<String>,
    pub(crate) following_url: Option<String>,
    pub(crate) gists_url: Option<String>,
    pub(crate) starred_url: Option<String>,
    pub(crate) subscriptions_url: Option<String>,
    pub(crate) organizations_url: Option<String>,
    pub(crate) repos_url: Option<String>,
    pub(crate) events_url: Option<String>,
    pub(crate) received_events_url: Option<String>,
    #[serde(rename = "type")]
    pub(crate) author_type: Option<String>,
    pub(crate) site_admin: Option<bool>,
}

async fn get_latest() -> anyhow::Result<ReleaseData> {
    let res = CLIENT
        .get("https://api.github.com/repos/NatroTeam/NatroMacro/releases/latest")
        .send()
        .await?
        .error_for_status()?;
    let release = res.json::<ReleaseResponse>().await?;
    let tag_name = release.tag_name.context("Should be able to get tag name")?;
    let assets = release.assets.context("Should be able to get asset")?;
    let zip: Asset = assets
        .iter()
        .filter(|asset| asset.content_type == Some("application/x-zip-compressed".to_string()))
        .collect::<Vec<&Asset>>()
        .remove(0)
        .clone();
    let exe = assets
        .iter()
        .filter(|asset| asset.content_type == Some("application/x-msdownload".to_string()))
        .last();
    Ok(ReleaseData {
        tag_name,
        zip,
        exe: exe.cloned(),
    })
}

async fn download(asset: Asset) -> anyhow::Result<bytes::Bytes> {
    let res = CLIENT
        .get(
            asset
                .browser_download_url
                .context("Should be able to get browser download url")?,
        )
        .send()
        .await?
        .error_for_status()?;

    let size = asset.size.context("Should be able to get asset size")? as u64;

    let pb = indicatif::ProgressBar::new(size);
    pb.set_style(
        indicatif::ProgressStyle::default_bar()
            .template("{spinner:.green} [{bar:40.cyan/blue}] {bytes}/{total_bytes} ({eta})")?
            .progress_chars("#>-"),
    );

    let mut downloaded: u64 = 0;
    let mut stream = res.bytes_stream();
    let mut bytes = Vec::new();

    while let Some(item) = stream.next().await {
        let chunk = item?;
        bytes.extend_from_slice(&chunk);
        let new = std::cmp::min(downloaded + (chunk.len() as u64), size);
        downloaded = new;
        pb.set_position(new);
    }

    pb.finish_with_message("Download completed");

    Ok(bytes.into())
}

fn get_grandparent(cd: &Path) -> Option<PathBuf> {
    cd.parent()
        .and_then(|p| p.parent().map(|p| p.to_path_buf()))
}
