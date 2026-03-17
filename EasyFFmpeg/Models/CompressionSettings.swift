import Foundation

struct CompressionSettings {
    var videoCodec: VideoCodec = .h265
    var crf: Int = 24
    var encoderPreset: EncoderPreset = .medium
    var tune: String? = nil
    var fps: Int? = nil
    var resolution: Resolution = .original
    var videoBitrate: Int? = nil

    var audioCodec: AudioCodec = .copy
    var audioBitrate: Int = 128
    var monoAudio: Bool = false

    static func from(preset: Preset) -> CompressionSettings {
        CompressionSettings(
            videoCodec: preset.videoCodec,
            crf: preset.crf ?? preset.videoCodec.defaultCRF,
            encoderPreset: preset.encoderPreset ?? .medium,
            tune: preset.tune,
            fps: preset.fps,
            resolution: preset.resolution ?? .original,
            videoBitrate: preset.videoBitrate,
            audioCodec: preset.audioCodec,
            audioBitrate: preset.audioBitrate ?? preset.audioCodec.defaultBitrate,
            monoAudio: preset.monoAudio
        )
    }

    /// Auto-fix audio codec for container compatibility
    mutating func autoSelectAudioCodec() {
        switch videoCodec {
        case .h264, .h265, .h265Hw:
            if audioCodec == .opus { audioCodec = .aac }
        case .vp9:
            if audioCodec == .aac { audioCodec = .opus }
        case .av1:
            break
        }
    }

    var recommendedContainer: String { videoCodec.recommendedContainer }

    func buildFFmpegArguments(
        inputPath: String,
        outputPath: String,
        progressFilePath: String,
        metadata: VideoMetadata?
    ) -> [String] {
        var args: [String] = []
        args += ["-i", inputPath]
        args += ["-y"]

        // Video filter chain — always includes format=yuv420p for compatibility
        var vfParts: [String] = []
        if let w = resolution.width {
            vfParts.append("scale=\(w):-2")
        } else {
            vfParts.append("crop=trunc(iw/2)*2:trunc(ih/2)*2")
        }
        vfParts.append("format=yuv420p")
        args += ["-vf", vfParts.joined(separator: ",")]

        // FPS — always force CFR; -vsync 1 works on all ffmpeg versions
        if let targetFps = fps {
            args += ["-r", "\(targetFps)"]
        } else if let meta = metadata {
            args += ["-r", roundToCommonFPS(meta.fps)]
        }
        args += ["-vsync", "1"]

        // Video codec
        args += ["-c:v", videoCodec.rawValue]

        switch videoCodec {
        case .h265Hw:
            let br = videoBitrate ?? 5000
            args += ["-b:v", "\(br)k", "-tag:v", "hvc1"]

        case .vp9:
            // VP9 uses CRF + b:v 0 for constrained quality mode
            args += ["-crf", "\(crf)", "-b:v", "0", "-row-mt", "1"]

        case .av1:
            // SVT-AV1 uses -preset 0-12 (not the standard ultrafast..veryslow)
            let svtPreset = svtAV1Preset(from: encoderPreset)
            args += ["-crf", "\(crf)", "-preset", "\(svtPreset)"]

        case .h264, .h265:
            args += ["-crf", "\(crf)", "-preset", encoderPreset.rawValue]
            if let tune = tune {
                args += ["-tune", tune]
            }
        }

        // Audio
        switch audioCodec {
        case .copy:
            args += ["-c:a", "copy"]
        case .flac:
            args += ["-c:a", "flac"]
        default:
            args += ["-c:a", audioCodec.rawValue, "-b:a", "\(audioBitrate)k"]
            if monoAudio { args += ["-ac", "1"] }
        }

        args += ["-progress", progressFilePath]
        args += ["-loglevel", "warning"]

        args.append(outputPath)
        return args
    }

    private func svtAV1Preset(from preset: EncoderPreset) -> Int {
        switch preset {
        case .ultrafast: return 10
        case .fast:      return 8
        case .medium:    return 6
        case .slow:      return 4
        case .slower:    return 2
        case .veryslow:  return 1
        }
    }
}

private func roundToCommonFPS(_ fps: Double) -> String {
    let common: [(Double, String)] = [
        (23.976, "24000/1001"), (24.0, "24"), (25.0, "25"),
        (29.97, "30000/1001"), (30.0, "30"),
        (50.0, "50"), (59.94, "60000/1001"), (60.0, "60"),
    ]
    let nearest = common.min { abs($0.0 - fps) < abs($1.0 - fps) }
    return nearest?.1 ?? String(Int(fps.rounded()))
}
