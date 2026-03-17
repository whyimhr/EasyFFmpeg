import Foundation

// MARK: - Video Codec

enum VideoCodec: String, CaseIterable, Identifiable {
    case h264      = "libx264"
    case h265      = "libx265"
    case h265Hw    = "hevc_videotoolbox"
    case vp9       = "libvpx-vp9"
    case av1       = "libsvtav1"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .h264:   return "H.264"
        case .h265:   return "H.265 (HEVC)"
        case .h265Hw: return "H.265 Apple Silicon"
        case .vp9:    return "VP9"
        case .av1:    return "AV1"
        }
    }

    var shortDescription: String { shortDescription(language: .russian) }
    func shortDescription(language: AppLanguage) -> String {
        switch self {
        case .h264:   return language == .english ? "Universal compatibility"          : "Универсальная совместимость"
        case .h265:   return language == .english ? "Best compression, modern standard" : "Лучшее сжатие, современный стандарт"
        case .h265Hw: return language == .english ? "Lightning fast on Mac"             : "Молниеносная скорость на Mac"
        case .vp9:    return language == .english ? "Open source, great for YouTube"    : "Открытый, отлично для YouTube"
        case .av1:    return language == .english ? "Maximum compression, slow"         : "Максимальное сжатие, медленно"
        }
    }

    var fullDescription: String { fullDescription(language: .russian) }
    func fullDescription(language: AppLanguage) -> String {
        switch self {
        case .h264:
            return language == .english
                ? "The most compatible codec in the world.\n\n✅ Plays everywhere\n✅ Fast encoding\n✅ Stable and proven\n\n❌ Files 30–50% larger than H.265\n❌ Aging standard\n\n📌 Use for old devices, TV sticks, email."
                : "Самый совместимый кодек в мире.\n\n✅ Воспроизводится везде\n✅ Быстрое кодирование\n✅ Стабильный и проверенный\n\n❌ Файлы на 30–50% больше, чем H.265\n❌ Устаревающий стандарт\n\n📌 Используйте для старых устройств, USB-телевизоров, email."
        case .h265:
            return language == .english
                ? "Modern standard with excellent compression.\n\n✅ 30–50% smaller at the same quality\n✅ 4K/8K, HDR support\n✅ Wide support (iPhone, Mac, Smart TV)\n\n❌ Slower than H.264\n❌ Not all old devices support it\n\n📌 Best choice for most cases."
                : "Современный стандарт с отличным сжатием.\n\n✅ На 30–50% меньше размер при том же качестве\n✅ Поддержка 4K/8K, HDR\n✅ Широкая поддержка (iPhone, Mac, Smart TV)\n\n❌ Медленнее кодирование, чем H.264\n❌ Не все старые устройства поддерживают\n\n📌 Лучший выбор для большинства случаев."
        case .h265Hw:
            return language == .english
                ? "Hardware encoding on Apple chips.\n\n✅ 5–10× faster than software H.265\n✅ Barely uses the CPU\n✅ Work in parallel\n\n❌ Slightly worse compression (10–20%)\n❌ Apple Silicon only (M1/M2/M3/M4)\n\n📌 For fast processing of many files."
                : "Аппаратное кодирование на чипах Apple.\n\n✅ В 5–10× быстрее программного H.265\n✅ Почти не нагружает процессор\n✅ Можно работать параллельно\n\n❌ Чуть хуже сжатие (на 10–20%)\n❌ Только на Apple Silicon (M1/M2/M3/M4)\n\n📌 Для быстрой обработки большого количества файлов."
        case .vp9:
            return language == .english
                ? "Open-source codec from Google.\n\n✅ Compression like H.265\n✅ Free, no patent restrictions\n✅ Native support in YouTube, Chrome, Android\n\n❌ Slow encoding\n❌ iPhone doesn't play natively\n❌ Limited Safari support\n\n📌 For websites and YouTube-optimized video."
                : "Открытый кодек от Google.\n\n✅ Сжатие как у H.265\n✅ Бесплатный, без патентных ограничений\n✅ Нативная поддержка YouTube, Chrome, Android\n\n❌ Медленное кодирование\n❌ iPhone не воспроизводит нативно\n❌ Safari поддержка ограничена\n\n📌 Для веб-сайтов и YouTube-оптимизированного видео."
        case .av1:
            return language == .english
                ? "Next-generation codec.\n\n✅ 30–50% better compression than H.265\n✅ Completely free and open\n✅ Supported by YouTube, Netflix, Chrome\n\n❌ Very slow encoding\n❌ Limited device support\n❌ Requires a powerful computer\n\n📌 For long-term archiving when time doesn't matter."
                : "Кодек следующего поколения.\n\n✅ На 30–50% лучше сжатие, чем H.265\n✅ Полностью бесплатный и открытый\n✅ Поддержка YouTube, Netflix, Chrome\n\n❌ Очень медленное кодирование\n❌ Пока ограниченная поддержка устройств\n❌ Требует мощный компьютер\n\n📌 Для долгосрочного архива, когда время не важно."
        }
    }

    var compressionEfficiency: Int {
        switch self { case .h264: return 3; case .h265, .h265Hw: return 4; case .vp9: return 4; case .av1: return 5 }
    }
    var encodingSpeed: Int {
        switch self { case .h264: return 4; case .h265: return 2; case .h265Hw: return 5; case .vp9: return 2; case .av1: return 1 }
    }
    var compatibility: Int {
        switch self { case .h264: return 5; case .h265, .h265Hw: return 4; case .vp9: return 3; case .av1: return 2 }
    }

    var defaultCRF: Int {
        switch self { case .h264: return 23; case .h265, .h265Hw: return 24; case .vp9: return 31; case .av1: return 30 }
    }
    var crfRange: ClosedRange<Int> {
        switch self { case .h264, .h265, .h265Hw: return 18...32; case .vp9, .av1: return 20...50 }
    }
    var crfLabel: String {
        switch self { case .vp9, .av1: return "Качество (0–63)"; default: return "CRF (качество)" }
    }
    var crfLabelEn: String {
        switch self { case .vp9, .av1: return "Quality (0–63)"; default: return "CRF (Quality)" }
    }

    var recommendedContainer: String {
        switch self { case .vp9: return "webm"; default: return "mp4" }
    }

    var isHardware: Bool { self == .h265Hw }

    var tags: [CodecTag] {
        switch self {
        case .h264:   return [.compatible, .fast]
        case .h265:   return [.recommended, .balanced]
        case .h265Hw: return [.fastest, .appleOnly]
        case .vp9:    return [.openSource, .webOptimized]
        case .av1:    return [.bestCompression, .slow]
        }
    }
}

enum CodecTag: String, Hashable {
    case recommended, fastest, bestCompression, compatible
    case balanced, openSource, webOptimized, appleOnly, slow, fast

    func displayName(_ lang: AppLanguage = .russian) -> String {
        switch self {
        case .recommended:      return lang == .english ? "Recommended"       : "Рекомендуется"
        case .fastest:          return lang == .english ? "Fastest"           : "Самый быстрый"
        case .bestCompression:  return lang == .english ? "Best compression"  : "Лучшее сжатие"
        case .compatible:       return lang == .english ? "Compatible"        : "Совместимый"
        case .balanced:         return lang == .english ? "Balanced"          : "Баланс"
        case .openSource:       return lang == .english ? "Open source"       : "Открытый"
        case .webOptimized:     return lang == .english ? "Web optimized"     : "Для веба"
        case .appleOnly:        return lang == .english ? "Apple only"        : "Только Apple"
        case .slow:             return lang == .english ? "Slow"              : "Медленный"
        case .fast:             return lang == .english ? "Fast"              : "Быстрый"
        }
    }

    var color: Color {
        switch self {
        case .recommended:     return .green
        case .fastest:         return .blue
        case .bestCompression: return .purple
        case .compatible:      return .orange
        case .balanced:        return .green
        case .openSource:      return .teal
        case .webOptimized:    return .indigo
        case .appleOnly:       return .gray
        case .slow:            return .red
        case .fast:            return .blue
        }
    }
}

// MARK: - Audio Codec

enum AudioCodec: String, CaseIterable, Identifiable {
    case copy  = "copy"
    case aac   = "aac"
    case opus  = "libopus"
    case mp3   = "libmp3lame"
    case flac  = "flac"

    var id: String { rawValue }

    func localizedDisplayName(_ lang: AppLanguage = .russian) -> String {
        switch self {
        case .copy: return lang == .english ? "Copy (unchanged)"     : "Без изменений"
        case .aac:  return "AAC"
        case .opus: return "Opus"
        case .mp3:  return "MP3"
        case .flac: return lang == .english ? "FLAC (lossless)"      : "FLAC (без потерь)"
        }
    }
    var displayName: String { localizedDisplayName(.russian) }

    func localizedShortDescription(_ lang: AppLanguage = .russian) -> String {
        switch self {
        case .copy: return lang == .english ? "Copy as-is — fast and lossless"              : "Копировать как есть — быстро и без потерь"
        case .aac:  return lang == .english ? "Standard for MP4, great compatibility"       : "Стандарт для MP4, отличная совместимость"
        case .opus: return lang == .english ? "Best quality at low bitrate"                 : "Лучшее качество при малом размере"
        case .mp3:  return lang == .english ? "Maximum compatibility, legacy"               : "Максимальная совместимость, устаревший"
        case .flac: return lang == .english ? "Lossless quality, large file"               : "Без потерь качества, большой размер"
        }
    }
    var shortDescription: String { localizedShortDescription(.russian) }

    func localizedFullDescription(_ lang: AppLanguage = .russian) -> String {
        switch self {
        case .copy: return lang == .english
            ? "Does not re-encode audio — copies the stream.\n\n✅ Instant, lossless\n✅ Preserves original tracks\n❌ Audio size won't shrink\n\n📌 Use by default."
            : "Не перекодирует аудио — копирует потоком.\n\n✅ Мгновенно, без потери качества\n✅ Сохраняет оригинальные дорожки\n❌ Размер аудио не уменьшится\n\n📌 Используйте по умолчанию."
        case .aac: return lang == .english
            ? "Standard codec for MP4/M4A.\n\n✅ Supported everywhere\n✅ Good quality at 128–192 kbps\n❌ Slightly behind Opus\n\n📌 Recommended for H.264/H.265 video."
            : "Стандартный кодек для MP4/M4A.\n\n✅ Поддерживается везде\n✅ Хорошее качество при 128–192 kbps\n❌ Немного уступает Opus\n\n📌 Рекомендуется для H.264/H.265 видео."
        case .opus: return lang == .english
            ? "Best modern audio codec.\n\n✅ Excellent quality even at 64 kbps\n✅ Ideal for voice and music\n❌ Not supported in MP4 (WebM/MKV only)\n\n📌 Best choice for VP9/AV1 video."
            : "Лучший современный аудиокодек.\n\n✅ Отличное качество даже при 64 kbps\n✅ Идеален для голоса и музыки\n❌ Не поддерживается в MP4 (только WebM/MKV)\n\n📌 Лучший выбор для VP9/AV1 видео."
        case .mp3: return lang == .english
            ? "Classic format.\n\n✅ Plays on any device\n❌ Worse quality than AAC/Opus\n❌ Legacy format\n\n📌 Only for compatibility with old devices."
            : "Классический формат.\n\n✅ Воспроизводится на любом устройстве\n❌ Хуже качество, чем AAC/Opus\n❌ Устаревший формат\n\n📌 Только для совместимости со старыми устройствами."
        case .flac: return lang == .english
            ? "Lossless compression.\n\n✅ Perfect quality\n✅ Can convert to any format\n❌ 2–3× larger than AAC\n\n📌 For archives and professional work."
            : "Сжатие без потерь.\n\n✅ Идеальное качество\n✅ Можно конвертировать в любой формат\n❌ Размер в 2–3× больше AAC\n\n📌 Для архивов и профессиональной работы."
        }
    }
    var fullDescription: String { localizedFullDescription(.russian) }

    var defaultBitrate: Int {
        switch self { case .copy, .flac: return 0; case .aac: return 128; case .opus: return 96; case .mp3: return 192 }
    }

    var hasBitrate: Bool {
        switch self { case .copy, .flac: return false; default: return true }
    }

    var compatibleWithMP4: Bool {
        switch self { case .copy, .aac, .mp3: return true; default: return false }
    }
}

// MARK: - Encoder Preset

enum EncoderPreset: String, CaseIterable, Identifiable {
    case ultrafast, fast, medium, slow, slower, veryslow
    var id: String { rawValue }
    var displayName: String { rawValue }

    // Fix 3: short label for narrow segmented controls
    var shortLabel: String {
        switch self {
        case .ultrafast: return "ufast"
        case .fast:      return "fast"
        case .medium:    return "med"
        case .slow:      return "slow"
        case .slower:    return "slower"
        case .veryslow:  return "vslow"
        }
    }

    var speedMultiplier: Double {
        switch self {
        case .ultrafast: return 12.0
        case .fast:      return 4.0
        case .medium:    return 2.0
        case .slow:      return 0.8
        case .slower:    return 0.4
        case .veryslow:  return 0.2
        }
    }
}

// MARK: - Resolution

enum Resolution: String, CaseIterable, Identifiable {
    case original = "original"
    case r4k      = "4K"
    case r1080p   = "1080p"
    case r720p    = "720p"
    case r480p    = "480p"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .original: return "Оригинальное"
        case .r4k:      return "4K (3840×auto)"
        case .r1080p:   return "1080p (1920×auto)"
        case .r720p:    return "720p (1280×auto)"
        case .r480p:    return "480p (854×auto)"
        }
    }
    func localizedDisplayName(_ lang: AppLanguage) -> String {
        if case .original = self { return L10n.string(.originalRes, language: lang) }
        return displayName
    }

    var width: Int? {
        switch self {
        case .original: return nil
        case .r4k:      return 3840
        case .r1080p:   return 1920
        case .r720p:    return 1280
        case .r480p:    return 854
        }
    }
}

// MARK: - Preset Category

enum PresetCategory: String, CaseIterable, Identifiable {
    case universal     = "Универсальные"
    case archive       = "Архив"
    case lecture       = "Лекции"
    case web           = "Веб / YouTube"
    case extreme       = "Макс. сжатие"
    case compatibility = "Совместимость"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .universal:     return "star.fill"
        case .archive:       return "archivebox.fill"
        case .lecture:       return "person.wave.2.fill"
        case .web:           return "globe"
        case .extreme:       return "arrow.down.circle.fill"
        case .compatibility: return "checkmark.seal.fill"
        }
    }

    var description: String {
        switch self {
        case .universal:     return "Подходят для большинства случаев"
        case .archive:       return "Для долгосрочного хранения"
        case .lecture:       return "Оптимизированы для статичного контента"
        case .web:           return "Для загрузки в интернет"
        case .extreme:       return "Когда размер важнее времени"
        case .compatibility: return "Для старых устройств"
        }
    }
}

// MARK: - Preset

struct Preset: Identifiable {
    let id: String
    let name: String          // Russian (default)
    let nameEn: String        // English
    let icon: String
    let category: PresetCategory
    let shortDescription: String       // Russian
    let shortDescriptionEn: String     // English

    // FFmpeg params
    let videoCodec: VideoCodec
    let crf: Int?
    let encoderPreset: EncoderPreset?
    let tune: String?
    let fps: Int?
    let resolution: Resolution?
    let videoBitrate: Int?
    let audioCodec: AudioCodec
    let audioBitrate: Int?
    let monoAudio: Bool

    // Info
    let fullDescription: String
    let fullDescriptionEn: String
    let compressionRatio: String
    let qualityStars: Int
    let timePerHour: String
    let timePerGB: String
    let useCases: [String]
    let useCasesEn: [String]
    let ffmpegCommand: String

    func localizedName(_ lang: AppLanguage) -> String {
        lang == .english ? nameEn : name
    }
    func localizedFullDesc(_ lang: AppLanguage) -> String {
        lang == .english && !fullDescriptionEn.isEmpty ? fullDescriptionEn : fullDescription
    }
    func localizedUseCases(_ lang: AppLanguage) -> [String] {
        lang == .english && !useCasesEn.isEmpty ? useCasesEn : useCases
    }
    func localizedShortDesc(_ lang: AppLanguage) -> String {
        lang == .english ? shortDescriptionEn : shortDescription
    }

    init(
        id: String, name: String, nameEn: String = "", icon: String, category: PresetCategory,
        shortDescription: String, shortDescriptionEn: String = "",
        videoCodec: VideoCodec, crf: Int? = nil,
        encoderPreset: EncoderPreset? = nil, tune: String? = nil,
        fps: Int? = nil, resolution: Resolution? = nil, videoBitrate: Int? = nil,
        audioCodec: AudioCodec = .copy, audioBitrate: Int? = nil, monoAudio: Bool = false,
        fullDescription: String, fullDescriptionEn: String = "",
        compressionRatio: String, qualityStars: Int,
        timePerHour: String, timePerGB: String,
        useCases: [String], useCasesEn: [String] = [], ffmpegCommand: String
    ) {
        self.id = id; self.name = name; self.nameEn = nameEn.isEmpty ? name : nameEn
        self.icon = icon; self.category = category
        self.shortDescription = shortDescription
        self.shortDescriptionEn = shortDescriptionEn.isEmpty ? shortDescription : shortDescriptionEn
        self.videoCodec = videoCodec
        self.crf = crf; self.encoderPreset = encoderPreset; self.tune = tune
        self.fps = fps; self.resolution = resolution; self.videoBitrate = videoBitrate
        self.audioCodec = audioCodec; self.audioBitrate = audioBitrate; self.monoAudio = monoAudio
        self.fullDescription = fullDescription
        self.fullDescriptionEn = fullDescriptionEn
        self.compressionRatio = compressionRatio
        self.qualityStars = qualityStars; self.timePerHour = timePerHour; self.timePerGB = timePerGB
        self.useCases = useCases; self.useCasesEn = useCasesEn; self.ffmpegCommand = ffmpegCommand
    }
}

// MARK: - SwiftUI Color import
import SwiftUI
