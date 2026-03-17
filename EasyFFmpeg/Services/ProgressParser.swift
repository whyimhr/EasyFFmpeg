import Foundation

struct EncodingProgress {
    let currentTime: Double   // seconds
    let speed: Double
    let totalDuration: Double
    var percentage: Double { totalDuration > 0 ? min(currentTime / totalDuration, 1.0) : 0 }
    var elapsed: TimeInterval
    var eta: TimeInterval? {
        guard speed > 0, currentTime > 0 else { return nil }
        let remaining = totalDuration - currentTime
        return remaining / speed
    }
}

class ProgressParser {
    private var currentTimeMs: Double = 0
    private var speed: Double = 0
    private let startTime = Date()
    let totalDuration: Double

    init(totalDuration: Double) {
        self.totalDuration = totalDuration
    }

    // Parse a single key=value line; returns updated progress when "progress=" line seen
    func parse(line: String) -> EncodingProgress? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let parts = trimmed.split(separator: "=", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return nil }
        let key = parts[0]
        let value = parts[1]

        switch key {
        case "out_time_ms":
            currentTimeMs = (Double(value) ?? 0) / 1_000_000
        case "out_time":
            // Fallback: parse HH:MM:SS.mmm
            currentTimeMs = parseTime(value)
        case "speed":
            let cleaned = value.replacingOccurrences(of: "x", with: "")
            speed = Double(cleaned) ?? speed
        case "progress":
            // "progress=continue" or "progress=end" — emit current state
            return EncodingProgress(
                currentTime: currentTimeMs,
                speed: speed,
                totalDuration: totalDuration,
                elapsed: Date().timeIntervalSince(startTime)
            )
        default:
            break
        }
        return nil
    }

    private func parseTime(_ s: String) -> Double {
        // Format: HH:MM:SS.mmm
        let parts = s.split(separator: ":").map(String.init)
        guard parts.count == 3 else { return 0 }
        let h = Double(parts[0]) ?? 0
        let m = Double(parts[1]) ?? 0
        let sec = Double(parts[2]) ?? 0
        return h * 3600 + m * 60 + sec
    }
}

extension TimeInterval {
    var formattedDuration: String {
        let total = Int(self)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }
}
