import Foundation

struct VideoMetadata {
    let fileName: String
    let fileSize: Int64
    let duration: Double        // seconds
    let width: Int
    let height: Int
    let fps: Double
    let videoCodec: String
    let videoBitrate: Int?      // kbps
    let audioCodec: String?
    let audioBitrate: Int?      // kbps

    var formattedSize: String {
        let gb = Double(fileSize) / 1_073_741_824
        if gb >= 1 {
            return String(format: "%.2f ГБ", gb)
        }
        let mb = Double(fileSize) / 1_048_576
        return String(format: "%.1f МБ", mb)
    }

    var formattedDuration: String {
        let total = Int(duration)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    var formattedResolution: String {
        "\(width)×\(height)"
    }

    var formattedFPS: String {
        if fps == Double(Int(fps)) {
            return "\(Int(fps)) FPS"
        }
        return String(format: "%.2f FPS", fps)
    }

    var pixelCount: Int { width * height }
}
