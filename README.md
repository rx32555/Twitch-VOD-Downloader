<div align="center">

# Twitch VOD Downloader & Chat Renderer

[![English](https://img.shields.io/badge/Lang-English-blue.svg)](README.md)
[![Español](https://img.shields.io/badge/Lang-Español-red.svg)](README.es.md)

**An automated, robust Batch script for Windows to easily download, archive, and play Twitch VODs with synchronized chat rendering.**

</div>

---

## Features

- **Automated Download**: Utilizes `yt-dlp` and `TwitchDownloaderCLI` to fetch video and chat seamlessly.
- **Chat Rendering**: Converts Twitch chat into a transparent overlay video (`.mp4`), ready for media players.
- **Portable Player**: Automatically generates a `.bat` launcher that syncs video + chat using `mpv` or `mpv.net`.
- **Multi-Language Support**: Interface available in [translate:English] and [translate:Spanish] (v1.1+).
- **Dependency Management**: Automatically downloads and configures all necessary tools (`ffmpeg`, `yt-dlp`, `.NET 6`, etc.) in an isolated local folder.
- **Session Persistence**: Saves user preferences (OAuth token, channel, language) locally.

## Prerequisites
- Windows 10/11 (64-bit recommended).

## Installation

1. Clone this repository or download the latest **Release**.
2. Run the file `Twitch-VOD-Downloader.bat`.
3. The script will automatically create the necessary directories (`ScriptFiles`, `output`, `userinfo`).

## Initial Configuration

Upon the first run, the script will ask for:

1.  **OAuth Token**: Required to download VODs (especially Sub-Only VODs).
    *   You can get this using browser extensions like "Get cookies.txt LOCALLY".
    *   The script includes a wizard to guide you through this.
2.  **Channel Name**: The target channel you want to list VODs from.
3.  **Language**: Select between [translate:English] or [translate:Spanish].

## Usage

1.  **Select VOD**: The menu will list the latest 10 VODs from the configured channel.
2.  **Download**: The script downloads both the video and the chat log.
3.  **Optional**: You can choose whether to render the chat or just keep the video.
4.  **Playback**: Upon completion, a launcher file is generated in the `output` folder (e.g., `Video_Name_VER_CON_CHAT.bat`). Run this file to watch the stream with the chat overlay as if it were live.
(Note: The generated launcher is fully portable. You can move the output folder to another PC, and it will try to use the system's .NET if the local tools are missing.)

## Folder Structure

- `/ScriptFiles`: Downloaded tools (ffmpeg, mpv, etc.). Not uploaded to the repo.
- `/output`: Destination for `.mp4` videos and launchers.
- `/userinfo`: Local tokens and config files (ignored by git).

## Contributing

Contributions are welcome! If you have ideas to improve the script, please open an "Issue" or submit a "Pull Request".

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---
**Note**: This script relies on third-party tools (`yt-dlp`, `TwitchDownloader`, `ffmpeg`, `mpv`). All credits go to their respective creators.
