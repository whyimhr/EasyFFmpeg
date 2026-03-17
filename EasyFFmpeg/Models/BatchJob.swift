import Foundation
import Combine

enum JobStatus: Equatable {
    case waiting
    case inProgress(progress: Double)
    case done(outputSize: Int64?)
    case failed(error: String)
    case skipped

    var displayName: String {
        switch self {
        case .waiting: return "Ожидает"
        case .inProgress(let p): return String(format: "%.0f%%", p * 100)
        case .done: return "Готово"
        case .failed: return "Ошибка"
        case .skipped: return "Пропущен"
        }
    }

    var color: String {
        switch self {
        case .waiting: return "secondary"
        case .inProgress: return "blue"
        case .done: return "green"
        case .failed: return "red"
        case .skipped: return "orange"
        }
    }
}

class BatchJob: ObservableObject, Identifiable {
    let id = UUID()
    let fileURL: URL
    @Published var isSelected: Bool = true
    @Published var status: JobStatus = .waiting
    var metadata: VideoMetadata?

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    var fileName: String { fileURL.lastPathComponent }

    var fileSize: Int64 {
        (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize).map(Int64.init) ?? 0
    }

    var formattedSize: String {
        let bytes = fileSize
        let gb = Double(bytes) / 1_073_741_824
        if gb >= 1 { return String(format: "%.2f ГБ", gb) }
        let mb = Double(bytes) / 1_048_576
        return String(format: "%.1f МБ", mb)
    }
}
