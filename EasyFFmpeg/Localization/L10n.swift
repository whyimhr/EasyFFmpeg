import Foundation

struct L10n {
    enum Key: String {
        // Sidebar
        case singleFile, batchProcessing, ffmpegMenu, help

        // SingleFileView
        case dragDropTitle, chooseFile, analyzing, analysisError
        case startEncoding, chooseAnotherFile
        case fileInfo, estimation, outputSettings, presetsTab, settingsTab

        // FileInfoView
        case labelFile, labelSize, labelDuration, labelResolution
        case labelFPS, labelVideoCodec, labelVideoBitrate
        case labelAudioCodec, labelAudioBitrate

        // EstimationView
        case original, expected, compression, timeLabel, savings

        // OutputSettingsView
        case fileName, saveFolder, changeFolder

        // Encoding
        case encoding, done, elapsed, remaining, speed, processed, cancel
        case encodingComplete, showInFinder, processAnother, encodingError, tryAgain

        // Preset / settings tabs
        case preset, manualSettings
        case compressionRatio, qualityLabel, timePerHour, timePerGB
        case recommendedFor, ffmpegCommand, presetDetails

        // Manual settings
        case videoCodec, crf, encodingSpeed, bitrate, fps, resolution, audio
        case maxQuality, minSize, fasterBigger, slowerSmaller
        case crfNote, presetNote
        case originalFPS, originalRes
        case copyAudio, audioBitrate, monoAudio, audioIncompatible
        case bitrateHeavy, balanceBitrate, goodBitrate, highBitrate

        // Codec ratings
        case ratingCompression, ratingSpeed, ratingCompatibility

        // Batch
        case batchOpenFolder, batchFiles, batchOf, batchStart, batchStop
        case batchStats, batchSelectedFiles, batchTotalSize
        case saveNextToOriginal, fileNameSuffix, notSelected
        case batchWaiting, batchDone, batchError, batchSkipped
        case batchProgress, batchFile, batchSaving

        // FFmpeg
        case ffmpegTitle, ffmpegStatus, ffmpegReady, ffmpegNotFound
        case ffmpegSource, ffmpegVersion, ffmpegPath, ffmpegInstallHint
        case ffmpegCheckUpdates, ffmpegChecking, ffmpegUpToDate, ffmpegUpdateAvailable
        case ffmpegUpdate, ffmpegNoConnection, ffmpegCheckAgain
        case ffmpegCodecSupport, ffmpegLicenses, ffmpegInstall
        case ffmpegInstallHomebrew, refresh, showLog, hideLog
        case ffmpegLicenseIntro, ffmpegLicenseNote, ffmpegLicenseLink
        case homebrewNotInstalled, homebrewInstallBtn, manualInstall

        // Help
        case helpTitle, howToChoose, presetComparison
        case videoCodecsSection, audioCodecsSection, parameters, commands, tips
        case situationLabel, recommendedPreset
        case crfExplainTitle, crfExplainBody
        case presetSpeedTitle, presetSpeedBody
        case crfValueCol, crfResultCol, crfUsageCol
        case presetSpeedCol, presetTimeCol
        case bestFor, detailedDesc

        // Help CRF table
        case crf18, crf21, crf25, crf28
        case crfRes18, crfRes21, crfRes25, crfRes28
        case crfUse18, crfUse21, crfUse25, crfUse28

        // Help preset table
        case presetTimeNote

        // Codec compare table
        case codecColName, codecColCompr, codecColSpeed, codecColCompat, codecColBestFor
        case h264BestFor, h265BestFor, h265hwBestFor, vp9BestFor, av1BestFor

        // Tips
        case tip1Title, tip1Text
        case tip2Title, tip2Text
        case tip3Title, tip3Text
        case tip4Title, tip4Text
        case tip5Title, tip5Text
        case tip6Title, tip6Text
        case tip7Title, tip7Text

        // How to choose table
        case howRow1, howRow2, howRow3, howRow4, howRow5, howRow6, howRow7, howRow8
        case howPreset1, howPreset2, howPreset3, howPreset4
        case howPreset5, howPreset6, howPreset7, howPreset8

        // Preset names
        case presetUniversal, presetUniversalFast
        case presetArchiveQuality, presetArchiveCompact
        case presetLecture, presetLectureCompact, presetLectureMinimal
        case presetYoutube, presetWebVP9
        case presetMaxCompression, presetCompatible

        // Codec names
        case h264Name, h264Short, h265Name, h265Short
        case h265hwName, h265hwShort, vp9Name, vp9Short, av1Name, av1Short

        // Audio codec names
        case copyName, copyShort, aacName, aacShort
        case opusName, opusShort, mp3Name, mp3Short, flacName, flacShort
    }

    static func string(_ key: Key, language: AppLanguage) -> String {
        switch language {
        case .russian: return ru[key] ?? en[key] ?? key.rawValue
        case .english: return en[key] ?? key.rawValue
        }
    }

    // MARK: — Russian
    static let ru: [Key: String] = [
        .singleFile: "Один файл", .batchProcessing: "Пакетная обработка",
        .ffmpegMenu: "FFmpeg", .help: "Справка",

        .dragDropTitle: "Перетащите видео или выберите файл",
        .chooseFile: "Выбрать файл…", .analyzing: "Анализируем файл…",
        .analysisError: "Ошибка анализа", .startEncoding: "Начать сжатие",
        .chooseAnotherFile: "Выбрать другой файл",

        .fileInfo: "Информация о файле", .estimation: "Оценка результата",
        .outputSettings: "Настройки вывода", .presetsTab: "Пресеты", .settingsTab: "Настройки",

        .labelFile: "Файл", .labelSize: "Размер", .labelDuration: "Длительность",
        .labelResolution: "Разрешение", .labelFPS: "FPS",
        .labelVideoCodec: "Видеокодек", .labelVideoBitrate: "Видеобитрейт",
        .labelAudioCodec: "Аудиокодек", .labelAudioBitrate: "Аудиобитрейт",

        .original: "Исходный", .expected: "Ожидаемый",
        .compression: "Сжатие", .timeLabel: "~Время", .savings: "Экономия",

        .fileName: "Имя файла", .saveFolder: "Папка сохранения", .changeFolder: "Изменить…",

        .encoding: "Кодирование", .done: "Готово", .elapsed: "Прошло",
        .remaining: "Осталось", .speed: "Скорость", .processed: "Обработано",
        .cancel: "Отменить", .encodingComplete: "Сжатие завершено",
        .showInFinder: "Показать в Finder", .processAnother: "Обработать другой",
        .encodingError: "Ошибка кодирования", .tryAgain: "Попробовать снова",

        .preset: "Пресет", .manualSettings: "Ручные настройки",
        .compressionRatio: "Сжатие", .qualityLabel: "Качество",
        .timePerHour: "Время на 1 час", .timePerGB: "Время на 1 ГБ",
        .recommendedFor: "Рекомендуется для", .ffmpegCommand: "Команда FFmpeg",
        .presetDetails: "Подробнее о пресете",

        .videoCodec: "Видеокодек", .crf: "CRF (качество)",
        .encodingSpeed: "Скорость кодирования", .bitrate: "Битрейт видео",
        .fps: "Частота кадров (FPS)", .resolution: "Разрешение", .audio: "Аудио",
        .maxQuality: "Макс. качество", .minSize: "Мин. размер",
        .fasterBigger: "Быстрее / больше файл", .slowerSmaller: "Медленнее / меньше файл",
        .crfNote: "Меньше = лучше качество, больший файл. Влияет сильнее, чем preset.",
        .presetNote: "Разница в размере между fast и slow обычно лишь 5–15%.",
        .originalFPS: "Оригинальный", .originalRes: "Оригинальное",
        .copyAudio: "Без изменений", .audioBitrate: "Битрейт аудио",
        .monoAudio: "Моно (для лекций, подкастов)",
        .audioIncompatible: "несовместим с MP4. Будет использован AAC.",
        .bitrateHeavy: "2500k — Сильное сжатие", .balanceBitrate: "4000k — Баланс",
        .goodBitrate: "5000k — Хорошее качество 1080p", .highBitrate: "8000k — 4K",
        .ratingCompression: "Сжатие", .ratingSpeed: "Скорость", .ratingCompatibility: "Совместимость",

        .batchOpenFolder: "Открыть папку", .batchFiles: "файлов", .batchOf: "из",
        .batchStart: "Начать обработку", .batchStop: "Остановить",
        .batchStats: "Статистика", .batchSelectedFiles: "Файлов выбрано",
        .batchTotalSize: "Общий размер", .saveNextToOriginal: "Сохранять рядом с оригиналом",
        .fileNameSuffix: "Суффикс имени", .notSelected: "Не выбрана",
        .batchWaiting: "Ожидает", .batchDone: "Готово", .batchError: "Ошибка", .batchSkipped: "Пропущен",
        .batchProgress: "Прогресс", .batchFile: "Файл", .batchSaving: "Сохранение",

        .ffmpegTitle: "Управление FFmpeg", .ffmpegStatus: "Статус FFmpeg",
        .ffmpegReady: "FFmpeg готов к работе", .ffmpegNotFound: "FFmpeg не найден",
        .ffmpegSource: "Источник", .ffmpegVersion: "Версия", .ffmpegPath: "Путь",
        .ffmpegInstallHint: "Установите FFmpeg через Homebrew",
        .ffmpegCheckUpdates: "Проверить обновления", .ffmpegChecking: "Проверка…",
        .ffmpegUpToDate: "актуален", .ffmpegUpdateAvailable: "Доступна версия",
        .ffmpegUpdate: "Обновить FFmpeg", .ffmpegNoConnection: "Нет подключения к интернету",
        .ffmpegCheckAgain: "Проверить снова",
        .ffmpegCodecSupport: "Поддержка кодеков", .ffmpegLicenses: "Лицензии",
        .ffmpegInstall: "Установить FFmpeg через Homebrew",
        .ffmpegInstallHomebrew: "Установить Homebrew + FFmpeg",
        .refresh: "Обновить", .showLog: "Показать лог", .hideLog: "Скрыть лог",
        .ffmpegLicenseIntro: "Это приложение использует **FFmpeg** — свободное программное обеспечение для обработки аудио и видео.",
        .ffmpegLicenseNote: "Для личного использования патентные ограничения H.264/H.265 практически не применяются.",
        .ffmpegLicenseLink: "Подробнее на ffmpeg.org/legal.html",
        .homebrewNotInstalled: "Homebrew не установлен. Для управления FFmpeg нужен Homebrew — пакетный менеджер для macOS.",
        .homebrewInstallBtn: "Установить Homebrew + FFmpeg",
        .manualInstall: "Команды для ручной установки",

        .helpTitle: "Справка", .howToChoose: "Как выбрать пресет?",
        .presetComparison: "Сравнение пресетов",
        .videoCodecsSection: "Сравнение видеокодеков", .audioCodecsSection: "Аудиокодеки",
        .parameters: "Параметры CRF и Preset", .commands: "Команды FFmpeg", .tips: "Полезные советы",
        .situationLabel: "Ситуация", .recommendedPreset: "Рекомендуемый пресет",
        .crfExplainTitle: "CRF (Constant Rate Factor) — главный параметр качества.",
        .crfExplainBody: "**Меньше значение = лучше качество, но больший файл.**",
        .presetSpeedTitle: "**Preset** — скорость кодирования.",
        .presetSpeedBody: "Разница в размере между fast и slow обычно лишь 5–15%.",
        .crfValueCol: "Значение", .crfResultCol: "Результат", .crfUsageCol: "Применение",
        .presetSpeedCol: "Скорость", .presetTimeCol: "Время на 1ч (≈)",
        .bestFor: "Лучше для", .detailedDesc: "Подробное описание",
        .crf18: "18–20", .crf21: "21–24", .crf25: "25–27", .crf28: "28–32",
        .crfRes18: "Почти без потерь", .crfRes21: "Высокое качество",
        .crfRes25: "Баланс", .crfRes28: "Сильное сжатие",
        .crfUse18: "Мастер-копии, монтаж", .crfUse21: "Универсальное",
        .crfUse25: "Лекции, архивы", .crfUse28: "Превью, мобильные",
        .presetTimeNote: "⚠️ Оценки для 1080p 30fps на Apple M1/M2. На Intel в 1.5–3× медленнее.",
        .codecColName: "Кодек", .codecColCompr: "Сжатие", .codecColSpeed: "Скорость",
        .codecColCompat: "Совмест.", .codecColBestFor: "Лучше для",
        .h264BestFor: "Старые устройства", .h265BestFor: "Большинство случаев",
        .h265hwBestFor: "Быстрая обработка", .vp9BestFor: "YouTube, веб", .av1BestFor: "Макс. сжатие",
        .tip1Title: "Не сжимайте уже сжатое",
        .tip1Text: "Повторное кодирование H.265 → H.265 только ухудшит качество без выигрыша в размере.",
        .tip2Title: "Совместимость с Apple",
        .tip2Text: "H.265 файлы воспроизводятся на iPhone/iPad/Mac/Apple TV без дополнительных настроек.",
        .tip3Title: "Аудио",
        .tip3Text: "По умолчанию аудио копируется без изменений (-c:a copy). Быстро и без потерь.",
        .tip4Title: "Тестируйте на фрагменте",
        .tip4Text: "Перед обработкой большого файла попробуйте настройки на 30-секундном фрагменте.",
        .tip5Title: "Скорость кодирования",
        .tip5Text: "FFmpeg показывает «speed=» — множитель. speed=2.0x: 1 час видео = 30 минут обработки.",
        .tip6Title: "Apple Silicon быстрее",
        .tip6Text: "На M1/M2/M3/M4 программное кодирование (libx265) значительно быстрее Intel Mac.",
        .tip7Title: "Открытые кодеки",
        .tip7Text: "VP9 и AV1 полностью свободны от патентов. H.264/H.265 — для личного использования ограничений нет.",
        .howRow1: "Не знаю, что выбрать", .howRow2: "Нужно быстро",
        .howRow3: "Важно качество", .howRow4: "Большой архив, экономия места",
        .howRow5: "Лекция / вебинар", .howRow6: "Для YouTube",
        .howRow7: "Минимальный размер", .howRow8: "Старые устройства / TV",
        .howPreset1: "Универсальное", .howPreset2: "Универсальное (быстрое)",
        .howPreset3: "Архив (макс. качество)", .howPreset4: "Архив (компактный)",
        .howPreset5: "Лекции и презентации", .howPreset6: "YouTube / Соцсети",
        .howPreset7: "Максимальное сжатие (AV1)", .howPreset8: "Максимальная совместимость",

        .presetUniversal: "Универсальное", .presetUniversalFast: "Универсальное (быстрое)",
        .presetArchiveQuality: "Архив (макс. качество)", .presetArchiveCompact: "Архив (компактный)",
        .presetLecture: "Лекции и презентации", .presetLectureCompact: "Лекции (компактные)",
        .presetLectureMinimal: "Лекции (минимальный размер)",
        .presetYoutube: "YouTube / Соцсети", .presetWebVP9: "Веб (VP9 + Opus)",
        .presetMaxCompression: "Максимальное сжатие (AV1)", .presetCompatible: "Максимальная совместимость",

        .h264Name: "H.264", .h264Short: "Универсальная совместимость",
        .h265Name: "H.265 (HEVC)", .h265Short: "Лучшее сжатие, современный стандарт",
        .h265hwName: "H.265 Apple Silicon", .h265hwShort: "Молниеносная скорость на Mac",
        .vp9Name: "VP9", .vp9Short: "Открытый, отлично для YouTube",
        .av1Name: "AV1", .av1Short: "Максимальное сжатие, медленно",
        .copyName: "Без изменений", .copyShort: "Копировать как есть — быстро и без потерь",
        .aacName: "AAC", .aacShort: "Стандарт для MP4, отличная совместимость",
        .opusName: "Opus", .opusShort: "Лучшее качество при малом размере",
        .mp3Name: "MP3", .mp3Short: "Максимальная совместимость, устаревший",
        .flacName: "FLAC (без потерь)", .flacShort: "Без потерь качества, большой размер",
    ]

    // MARK: — English
    static let en: [Key: String] = [
        .singleFile: "Single File", .batchProcessing: "Batch Processing",
        .ffmpegMenu: "FFmpeg", .help: "Help",

        .dragDropTitle: "Drop video here or choose a file",
        .chooseFile: "Choose File…", .analyzing: "Analyzing file…",
        .analysisError: "Analysis error", .startEncoding: "Start Compression",
        .chooseAnotherFile: "Choose Another File",

        .fileInfo: "File Info", .estimation: "Estimated Result",
        .outputSettings: "Output Settings", .presetsTab: "Presets", .settingsTab: "Settings",

        .labelFile: "File", .labelSize: "Size", .labelDuration: "Duration",
        .labelResolution: "Resolution", .labelFPS: "FPS",
        .labelVideoCodec: "Video Codec", .labelVideoBitrate: "Video Bitrate",
        .labelAudioCodec: "Audio Codec", .labelAudioBitrate: "Audio Bitrate",

        .original: "Original", .expected: "Estimated",
        .compression: "Compression", .timeLabel: "~Time", .savings: "Savings",

        .fileName: "File Name", .saveFolder: "Save Folder", .changeFolder: "Change…",

        .encoding: "Encoding", .done: "Done", .elapsed: "Elapsed",
        .remaining: "Remaining", .speed: "Speed", .processed: "Processed",
        .cancel: "Cancel", .encodingComplete: "Compression complete",
        .showInFinder: "Show in Finder", .processAnother: "Process Another",
        .encodingError: "Encoding Error", .tryAgain: "Try Again",

        .preset: "Preset", .manualSettings: "Manual Settings",
        .compressionRatio: "Compression", .qualityLabel: "Quality",
        .timePerHour: "Time per 1h", .timePerGB: "Time per 1 GB",
        .recommendedFor: "Recommended for", .ffmpegCommand: "FFmpeg Command",
        .presetDetails: "Preset Details",

        .videoCodec: "Video Codec", .crf: "CRF (Quality)",
        .encodingSpeed: "Encoding Speed", .bitrate: "Video Bitrate",
        .fps: "Frame Rate (FPS)", .resolution: "Resolution", .audio: "Audio",
        .maxQuality: "Max quality", .minSize: "Min size",
        .fasterBigger: "Faster / larger file", .slowerSmaller: "Slower / smaller file",
        .crfNote: "Lower = better quality, larger file. Affects result more than preset.",
        .presetNote: "Size difference between fast and slow is usually only 5–15%.",
        .originalFPS: "Original", .originalRes: "Original",
        .copyAudio: "Copy (no change)", .audioBitrate: "Audio Bitrate",
        .monoAudio: "Mono (for lectures, podcasts)",
        .audioIncompatible: "is incompatible with MP4. AAC will be used.",
        .bitrateHeavy: "2500k — Heavy compression", .balanceBitrate: "4000k — Balance",
        .goodBitrate: "5000k — Good quality 1080p", .highBitrate: "8000k — 4K",
        .ratingCompression: "Compression", .ratingSpeed: "Speed", .ratingCompatibility: "Compatibility",

        .batchOpenFolder: "Open Folder", .batchFiles: "files", .batchOf: "of",
        .batchStart: "Start Processing", .batchStop: "Stop",
        .batchStats: "Statistics", .batchSelectedFiles: "Files selected",
        .batchTotalSize: "Total size", .saveNextToOriginal: "Save next to originals",
        .fileNameSuffix: "File name suffix", .notSelected: "Not selected",
        .batchWaiting: "Waiting", .batchDone: "Done", .batchError: "Error", .batchSkipped: "Skipped",
        .batchProgress: "Progress", .batchFile: "File", .batchSaving: "Save to",

        .ffmpegTitle: "FFmpeg Management", .ffmpegStatus: "FFmpeg Status",
        .ffmpegReady: "FFmpeg is ready", .ffmpegNotFound: "FFmpeg not found",
        .ffmpegSource: "Source", .ffmpegVersion: "Version", .ffmpegPath: "Path",
        .ffmpegInstallHint: "Install FFmpeg via Homebrew",
        .ffmpegCheckUpdates: "Check for Updates", .ffmpegChecking: "Checking…",
        .ffmpegUpToDate: "is up to date", .ffmpegUpdateAvailable: "Update available:",
        .ffmpegUpdate: "Update FFmpeg", .ffmpegNoConnection: "No internet connection",
        .ffmpegCheckAgain: "Check again",
        .ffmpegCodecSupport: "Codec Support", .ffmpegLicenses: "Licenses",
        .ffmpegInstall: "Install FFmpeg via Homebrew",
        .ffmpegInstallHomebrew: "Install Homebrew + FFmpeg",
        .refresh: "Refresh", .showLog: "Show log", .hideLog: "Hide log",
        .ffmpegLicenseIntro: "This app uses **FFmpeg** — free software for audio and video processing.",
        .ffmpegLicenseNote: "For personal use, patent restrictions on H.264/H.265 generally do not apply.",
        .ffmpegLicenseLink: "Learn more at ffmpeg.org/legal.html",
        .homebrewNotInstalled: "Homebrew is not installed. Homebrew is required to manage FFmpeg updates.",
        .homebrewInstallBtn: "Install Homebrew + FFmpeg",
        .manualInstall: "Manual install commands",

        .helpTitle: "Help", .howToChoose: "How to Choose a Preset?",
        .presetComparison: "Preset Comparison",
        .videoCodecsSection: "Video Codec Comparison", .audioCodecsSection: "Audio Codecs",
        .parameters: "CRF and Preset Parameters", .commands: "FFmpeg Commands", .tips: "Tips & Tricks",
        .situationLabel: "Situation", .recommendedPreset: "Recommended Preset",
        .crfExplainTitle: "CRF (Constant Rate Factor) — the main quality parameter.",
        .crfExplainBody: "**Lower value = better quality, but larger file.**",
        .presetSpeedTitle: "**Preset** — encoding speed.",
        .presetSpeedBody: "Size difference between fast and slow is usually only 5–15%.",
        .crfValueCol: "Value", .crfResultCol: "Result", .crfUsageCol: "Use case",
        .presetSpeedCol: "Speed", .presetTimeCol: "Time per 1h (≈)",
        .bestFor: "Best for", .detailedDesc: "Detailed description",
        .crf18: "18–20", .crf21: "21–24", .crf25: "25–27", .crf28: "28–32",
        .crfRes18: "Near lossless", .crfRes21: "High quality",
        .crfRes25: "Balanced", .crfRes28: "Heavy compression",
        .crfUse18: "Master copies, editing", .crfUse21: "Universal",
        .crfUse25: "Lectures, archives", .crfUse28: "Previews, mobile",
        .presetTimeNote: "⚠️ Estimates for 1080p 30fps on Apple M1/M2. Intel Macs are 1.5–3× slower.",
        .codecColName: "Codec", .codecColCompr: "Compression", .codecColSpeed: "Speed",
        .codecColCompat: "Compat.", .codecColBestFor: "Best for",
        .h264BestFor: "Legacy devices", .h265BestFor: "Most cases",
        .h265hwBestFor: "Fast processing", .vp9BestFor: "YouTube, web", .av1BestFor: "Max compression",
        .tip1Title: "Don't re-compress already compressed files",
        .tip1Text: "Re-encoding H.265 → H.265 will only reduce quality with no size benefit.",
        .tip2Title: "Apple device compatibility",
        .tip2Text: "H.265 files play natively on iPhone, iPad, Mac and Apple TV.",
        .tip3Title: "Audio",
        .tip3Text: "Audio is copied unchanged by default (-c:a copy). Fast and lossless.",
        .tip4Title: "Test on a short clip first",
        .tip4Text: "Before processing a large file, try your settings on a 30-second segment.",
        .tip5Title: "Encoding speed indicator",
        .tip5Text: "FFmpeg shows 'speed=' — a realtime multiplier. speed=2.0x means 1 hour takes 30 minutes.",
        .tip6Title: "Apple Silicon is faster",
        .tip6Text: "On M1/M2/M3/M4, software encoding (libx265) is significantly faster than Intel Macs.",
        .tip7Title: "Open codecs",
        .tip7Text: "VP9 and AV1 are fully patent-free. H.264/H.265 — no restrictions for personal use.",
        .howRow1: "I don't know what to choose", .howRow2: "Need it fast",
        .howRow3: "Quality matters", .howRow4: "Large archive, save space",
        .howRow5: "Lecture / webinar", .howRow6: "For YouTube",
        .howRow7: "Minimum size", .howRow8: "Old devices / TV",
        .howPreset1: "Universal", .howPreset2: "Universal (Fast)",
        .howPreset3: "Archive (Max Quality)", .howPreset4: "Archive (Compact)",
        .howPreset5: "Lectures & Presentations", .howPreset6: "YouTube / Social",
        .howPreset7: "Maximum Compression (AV1)", .howPreset8: "Maximum Compatibility",

        .presetUniversal: "Universal", .presetUniversalFast: "Universal (Fast)",
        .presetArchiveQuality: "Archive (Max Quality)", .presetArchiveCompact: "Archive (Compact)",
        .presetLecture: "Lectures & Presentations", .presetLectureCompact: "Lectures (Compact)",
        .presetLectureMinimal: "Lectures (Minimum Size)",
        .presetYoutube: "YouTube / Social", .presetWebVP9: "Web (VP9 + Opus)",
        .presetMaxCompression: "Maximum Compression (AV1)", .presetCompatible: "Maximum Compatibility",

        .h264Name: "H.264", .h264Short: "Universal compatibility",
        .h265Name: "H.265 (HEVC)", .h265Short: "Best compression, modern standard",
        .h265hwName: "H.265 Apple Silicon", .h265hwShort: "Lightning fast on Mac",
        .vp9Name: "VP9", .vp9Short: "Open source, great for YouTube",
        .av1Name: "AV1", .av1Short: "Maximum compression, slow",
        .copyName: "Copy (unchanged)", .copyShort: "Copy as-is — fast and lossless",
        .aacName: "AAC", .aacShort: "Standard for MP4, great compatibility",
        .opusName: "Opus", .opusShort: "Best quality at low bitrate",
        .mp3Name: "MP3", .mp3Short: "Maximum compatibility, legacy",
        .flacName: "FLAC (lossless)", .flacShort: "Lossless quality, large file",
    ]
}
