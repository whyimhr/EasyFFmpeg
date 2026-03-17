import Foundation

class FFprobeAnalyzer {
    static let shared = FFprobeAnalyzer()

    private var ffprobePath: String? {
        let candidates = [
            Bundle.main.bundlePath + "/Contents/MacOS/ffprobe",
            "/opt/homebrew/bin/ffprobe",
            "/usr/local/bin/ffprobe"
        ]
        return candidates.first { FileManager.default.fileExists(atPath: $0) }
    }

    func analyze(url: URL) async throws -> VideoMetadata {
        guard let path = ffprobePath else {
            throw AppError.ffmpegNotFound
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = [
            "-v", "quiet",
            "-print_format", "json",
            "-show_format",
            "-show_streams",
            url.path
        ]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return try parseFFprobeOutput(data, fileName: url.lastPathComponent, fileURL: url)
    }

    private func parseFFprobeOutput(_ data: Data, fileName: String, fileURL: URL) throws -> VideoMetadata {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AppError.analysisFailure("Не удалось разобрать вывод ffprobe")
        }

        let streams = json["streams"] as? [[String: Any]] ?? []
        let format = json["format"] as? [String: Any] ?? [:]

        // Duration
        let durationStr = (format["duration"] as? String) ?? "0"
        let duration = Double(durationStr) ?? 0

        // File size
        let fileSizeStr = (format["size"] as? String) ?? "0"
        let fileSize = Int64(fileSizeStr) ?? 0

        // Video stream
        let videoStream = streams.first { ($0["codec_type"] as? String) == "video" } ?? [:]
        let audioStream = streams.first { ($0["codec_type"] as? String) == "audio" }

        let width = (videoStream["width"] as? Int) ?? 0
        let height = (videoStream["height"] as? Int) ?? 0
        let videoCodec = (videoStream["codec_name"] as? String) ?? "unknown"
        let fps = parseFPS(videoStream["r_frame_rate"] as? String)

        let videoBitrateStr = videoStream["bit_rate"] as? String
        let videoBitrate = videoBitrateStr.flatMap { Int($0) }.map { $0 / 1000 }

        let audioCodec = audioStream?["codec_name"] as? String
        let audioBitrateStr = audioStream?["bit_rate"] as? String
        let audioBitrate = audioBitrateStr.flatMap { Int($0) }.map { $0 / 1000 }

        return VideoMetadata(
            fileName: fileName,
            fileSize: fileSize,
            duration: duration,
            width: width,
            height: height,
            fps: fps,
            videoCodec: videoCodec,
            videoBitrate: videoBitrate,
            audioCodec: audioCodec,
            audioBitrate: audioBitrate
        )
    }

    private func parseFPS(_ str: String?) -> Double {
        guard let str = str else { return 30 }
        let parts = str.split(separator: "/").map { Double($0) ?? 0 }
        if parts.count == 2 && parts[1] > 0 {
            return parts[0] / parts[1]
        }
        return Double(str) ?? 30
    }
}

enum AppError: LocalizedError {
    case ffmpegNotFound
    case analysisFailure(String)
    case encodingFailed(String)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .ffmpegNotFound:
            return "FFmpeg не найден. Установите его через Homebrew: brew install ffmpeg"
        case .analysisFailure(let msg):
            return "Ошибка анализа: \(msg)"
        case .encodingFailed(let msg):
            return "Ошибка кодирования: \(msg)"
        case .cancelled:
            return "Отменено пользователем"
        }
    }
}
