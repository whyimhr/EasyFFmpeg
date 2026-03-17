# EasyFFmpeg

A native macOS video compression app built with SwiftUI and FFmpeg.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- **Single file** and **batch** compression
- 11 presets across 6 categories (Universal, Archive, Lectures, Web, Extreme, Compatibility)
- Codecs: H.264, H.265, H.265 Apple Silicon (hardware), VP9, AV1
- Audio: Copy, AAC, Opus, MP3, FLAC
- Real-time encoding progress with speed, ETA, and compression estimate
- Post-encoding summary: time elapsed, size saved, compression ratio
- FFmpeg management — detects Homebrew install, checks for updates
- **English / Russian** UI localization
- macOS 13+ (Ventura and later)

## Requirements

- macOS 13.0 or later
- Xcode 15+
- FFmpeg installed via Homebrew:
```bash
brew install ffmpeg
```

## Installation

1. Clone the repository
2. Open `EasyFFmpeg.xcodeproj` in Xcode
3. Select your signing team in **Signing & Capabilities**
4. Build and run (⌘R)

FFmpeg is detected automatically from `/opt/homebrew/bin/ffmpeg` or `/usr/local/bin/ffmpeg`.

## Download

👉 Download the latest version from [**Releases**](../../releases)

## Install from DMG

1. Download the `.dmg` from Releases
2. Open the `.dmg`
3. Drag **EasyFFmpeg.app** into **Applications**
4. Launch the app

If macOS blocks the app, run in Terminal:
```bash
xattr -rd com.apple.quarantine /Applications/EasyFFmpeg.app
```

## Project Structure

```
EasyFFmpeg/
├── EasyFFmpegApp.swift         # App entry point (@main)
├── Models/
│   ├── Preset.swift            # Preset, VideoCodec, AudioCodec, Resolution
│   ├── CompressionSettings.swift   # FFmpeg argument builder
│   ├── CompletionStats.swift   # Post-encoding result stats
│   ├── VideoMetadata.swift     # File metadata
│   └── BatchJob.swift          # Batch processing job model
├── Presets.swift               # All 11 preset definitions
├── Services/
│   ├── FFmpegRunner.swift      # Process launch, progress, cancellation
│   ├── FFmpegManager.swift     # FFmpeg detection, Homebrew management
│   ├── FFprobeAnalyzer.swift   # Video file analysis
│   ├── ProgressParser.swift    # FFmpeg -progress output parser
│   └── SizeEstimator.swift     # Output size/time estimation
├── ViewModels/
│   ├── MainViewModel.swift     # Single file screen state
│   └── BatchViewModel.swift    # Batch processing state
├── Views/                      # All SwiftUI views
└── Localization/
    ├── L10n.swift              # All strings (RU + EN)
    ├── LanguageManager.swift   # Language persistence
    └── LanguagePickerView.swift
```

## FFmpeg Notes

- Progress written to a **temp file** (not pipe) to avoid stderr buffer deadlock
- `-vsync 1` for ffmpeg 7.x compatibility
- `format=yuv420p` inside `-vf` chain for pixel format compatibility
- `-tag:v hvc1` added for both `libx265` and `hevc_videotoolbox` — required for QuickTime / Apple ecosystem playback
- `IOPMAssertionCreateWithName` prevents sleep during encoding

## License

MIT License — see [LICENSE](LICENSE) for details.

This app uses **FFmpeg**, licensed under LGPL 2.1+ / GPL 2+.  
See [ffmpeg.org/legal.html](https://ffmpeg.org/legal.html) for codec licensing details.
