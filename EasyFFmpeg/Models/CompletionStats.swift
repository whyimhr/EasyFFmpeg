import Foundation

/// Results shown after encoding completes
struct CompletionStats {
    let elapsedSeconds: Double
    let inputBytes: Int64
    let outputBytes: Int64

    var savedBytes: Int64 { max(inputBytes - outputBytes, 0) }
    var ratio: Double { Double(inputBytes) / Double(max(outputBytes, 1)) }
    var savedPercent: Int { Int((1.0 - Double(outputBytes) / Double(max(inputBytes, 1))) * 100) }

    var formattedElapsed: String {
        let s = Int(elapsedSeconds)
        let h = s / 3600; let m = (s % 3600) / 60; let sec = s % 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m \(sec)s" }
        return "\(sec)s"
    }

    var formattedInput: String  { formatBytes(inputBytes) }
    var formattedOutput: String { formatBytes(outputBytes) }
    var formattedSaved: String  { formatBytes(savedBytes) }

    private func formatBytes(_ b: Int64) -> String {
        let gb = Double(b) / 1_073_741_824
        if gb >= 1 { return String(format: "%.2f GB", gb) }
        return String(format: "%.0f MB", Double(b) / 1_048_576)
    }
}
