import Foundation

struct EstimationResult {
    let estimatedBytes: Int64
    let compressionRatio: Double
    let encodingSeconds: Double

    var formattedSize: String {
        let gb = Double(estimatedBytes) / 1_073_741_824
        if gb >= 1 { return String(format: "%.2f ГБ", gb) }
        let mb = Double(estimatedBytes) / 1_048_576
        return String(format: "%.0f МБ", mb)
    }

    var formattedTime: String {
        let secs = Int(encodingSeconds)
        let h = secs / 3600; let m = (secs % 3600) / 60
        if h > 0 { return "~\(h) ч \(m) мин" }
        if m > 0 { return "~\(m) мин" }
        return "~\(secs) сек"
    }
}

class SizeEstimator {
    static func estimate(settings: CompressionSettings, metadata: VideoMetadata) -> EstimationResult {
        let targetWidth  = settings.resolution.width ?? metadata.width
        let targetHeight = targetWidth == metadata.width
            ? metadata.height
            : Int(Double(metadata.height) * Double(targetWidth) / Double(metadata.width))
        let targetFPS  = Double(settings.fps ?? Int(metadata.fps))
        let duration   = metadata.duration

        let encTime = estimateEncodingTime(
            settings: settings, metadata: metadata,
            targetWidth: targetWidth, targetFPS: targetFPS
        )

        // ── Hardware encoder ──────────────────────────────────────────
        if settings.videoCodec.isHardware {
            let targetKbps = Double(settings.videoBitrate ?? 5000)
            let sourceKbps = sourceVideoBitrate(metadata: metadata)

            // If target bitrate ≥ source, output won't be smaller
            let effectiveKbps = targetKbps < sourceKbps ? targetKbps : sourceKbps
            var est = Int64(effectiveKbps * 1000 / 8 * duration)
            est += audioBytes(settings: settings, metadata: metadata, duration: duration)
            est = max(est, metadata.fileSize / 100)
            let ratio = Double(metadata.fileSize) / Double(max(est, 1))
            return EstimationResult(estimatedBytes: est, compressionRatio: ratio, encodingSeconds: encTime)
        }

        // ── Software encoder ─────────────────────────────────────────
        let bitrateKbps = estimateBitrate(
            codec: settings.videoCodec, crf: settings.crf,
            width: targetWidth, height: targetHeight, fps: targetFPS
        )

        var est = Int64(bitrateKbps * 1000 / 8 * duration)
        est += audioBytes(settings: settings, metadata: metadata, duration: duration)

        // Hard cap: output can't exceed source (if formula overestimates, clamp to source)
        est = min(est, metadata.fileSize)
        est = max(est, metadata.fileSize / 100)

        let ratio = Double(metadata.fileSize) / Double(max(est, 1))
        return EstimationResult(estimatedBytes: est, compressionRatio: ratio, encodingSeconds: encTime)
    }

    // MARK: - Bitrate per codec
    // Calibrated against real-world encodes of 1080p 30fps content.

    private static func estimateBitrate(
        codec: VideoCodec, crf: Int,
        width: Int, height: Int, fps: Double
    ) -> Double {
        let pixels = Double(width * height)

        switch codec {
        case .h265, .h265Hw:
            // Reference: CRF 23 ≈ 3110 kbps for 1080p 30fps
            // Coefficient 0.05 calibrated from real libx265 output
            let bpp = 0.05 * pow(2, Double(23 - crf) / 6.0)
            return pixels * bpp * fps / 1000

        case .h264:
            // H.264 is ~40% less efficient than H.265 at same perceptual quality
            // Reference: CRF 23 ≈ 4356 kbps for 1080p 30fps
            let bpp = 0.07 * pow(2, Double(23 - crf) / 6.0)
            return pixels * bpp * fps / 1000

        case .vp9:
            // VP9 CRF scale 0-63 (0=lossless, 63=worst).
            // Quadratic formula: CRF 31 ≈ 1493 kbps for 1080p 30fps
            // Coefficient 0.093 calibrated for constrained-quality mode (-b:v 0)
            let norm = 1.0 - Double(crf) / 63.0
            let bpp = 0.093 * norm * norm
            return pixels * bpp * fps / 1000

        case .av1:
            // SVT-AV1 CRF scale 0-63. ~30% more efficient than VP9.
            // CRF 32 ≈ 979 kbps for 1080p 30fps
            let norm = 1.0 - Double(crf) / 63.0
            let bpp = 0.065 * norm * norm
            return pixels * bpp * fps / 1000
        }
    }

    // MARK: - Audio size

    private static func audioBytes(
        settings: CompressionSettings, metadata: VideoMetadata, duration: Double
    ) -> Int64 {
        switch settings.audioCodec {
        case .copy:
            return Int64(Double(metadata.audioBitrate ?? 128) * 1000 / 8 * duration)
        case .flac:
            return Int64(Double(metadata.audioBitrate ?? 1411) * 1000 / 8 * duration)
        default:
            return Int64(Double(settings.audioBitrate) * 1000 / 8 * duration)
        }
    }

    // MARK: - Source bitrate helper

    private static func sourceVideoBitrate(metadata: VideoMetadata) -> Double {
        if let sb = metadata.videoBitrate, sb > 0 { return Double(sb) }
        // Estimate from file size if bitrate metadata missing
        return Double(metadata.fileSize) * 8 / metadata.duration / 1000
    }

    // MARK: - Encoding time

    private static func estimateEncodingTime(
        settings: CompressionSettings, metadata: VideoMetadata,
        targetWidth: Int, targetFPS: Double
    ) -> Double {
        let baseSpeed: Double
        switch settings.videoCodec {
        case .h264:   baseSpeed = 3.0
        case .h265:   baseSpeed = 1.5
        case .h265Hw: baseSpeed = 15.0
        case .vp9:    baseSpeed = 0.8
        case .av1:    baseSpeed = 0.3
        }

        let presetMult: Double
        switch settings.encoderPreset {
        case .ultrafast: presetMult = 4.0
        case .fast:      presetMult = 2.0
        case .medium:    presetMult = 1.0
        case .slow:      presetMult = 0.5
        case .slower:    presetMult = 0.25
        case .veryslow:  presetMult = 0.1
        }

        let origPx = metadata.width * metadata.height
        let targPx = targetWidth * (metadata.height * targetWidth / metadata.width)
        let resFactor = sqrt(Double(origPx) / Double(max(targPx, 1)))
        let fpsFactor = metadata.fps / max(targetFPS, 1)

        let speed = baseSpeed * presetMult * resFactor * fpsFactor
        return metadata.duration / max(speed, 0.01)
    }
}
