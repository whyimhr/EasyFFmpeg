import Foundation

extension Preset {
    static let all: [Preset] = [
        // Universal
        universal, universalFast,
        // Archive
        archiveQuality, archiveCompact,
        // Lectures
        lecture, lectureCompact, lectureMinimal,
        // Web
        youtube, webVP9,
        // Extreme
        maximumCompression,
        // Compatibility
        compatible
    ]

    static func forCategory(_ cat: PresetCategory) -> [Preset] {
        all.filter { $0.category == cat }
    }

    // MARK: Universal

    static let universal = Preset(
        id: "universal",
        name: "Универсальное",
        nameEn: "Universal",
        icon: "star.fill",
        category: .universal,
        shortDescription: "Оптимальный баланс для большинства видео",
        shortDescriptionEn: "Optimal balance for most videos",
        videoCodec: .h265, crf: 24, encoderPreset: .medium,
        fullDescription: "Лучший выбор, если не знаете, что выбрать.\n\n• Современный кодек H.265 с отличным сжатием\n• Сохраняет высокое качество видео\n• Аудио копируется без изменений\n• Работает на большинстве современных устройств",
        fullDescriptionEn: "Best choice when you're not sure what to pick.\n\n• Modern H.265 codec with great compression\n• Preserves high video quality\n• Audio copied unchanged\n• Works on most modern devices",
        compressionRatio: "3–5×", qualityStars: 4,
        timePerHour: "30–50 мин", timePerGB: "15–25 мин",
        useCases: ["Домашние видео", "Записи с телефона", "Скачанные фильмы", "Общий архив"],
        useCasesEn: ["Home videos", "Phone recordings", "Downloaded movies", "General archive"],
        ffmpegCommand: "ffmpeg -i \"input.mp4\" -vf format=yuv420p -r 30 -vsync 1 \\\n  -c:v libx265 -crf 24 -preset medium -c:a copy output.mp4"
    )

    static let universalFast = Preset(
        id: "universal_fast",
        name: "Универсальное (быстрое)",
        nameEn: "Universal (Fast)",
        icon: "hare.fill",
        category: .universal,
        shortDescription: "Аппаратное кодирование Apple Silicon — в 5–10× быстрее",
        shortDescriptionEn: "Apple Silicon hardware encoding — 5–10× faster",
        videoCodec: .h265Hw, videoBitrate: 5000,
        fullDescription: "Использует аппаратный кодировщик Apple Silicon.\n\n• В 5–10× быстрее программного кодирования\n• Отличное качество (5 Mbps для 1080p)\n• Минимальная нагрузка на батарею\n• Идеально для большого количества файлов",
        fullDescriptionEn: "Uses Apple Silicon hardware encoder.\n\n• 5–10× faster than software encoding\n• Excellent quality (5 Mbps for 1080p)\n• Minimal battery impact\n• Ideal for processing many files at once",
        compressionRatio: "2–4×", qualityStars: 4,
        timePerHour: "5–10 мин", timePerGB: "3–6 мин",
        useCases: ["Много файлов", "Быстрая обработка", "Работа от батареи", "Предварительный просмотр"],
        useCasesEn: ["Many files", "Fast processing", "Battery life", "Preview renders"],
        ffmpegCommand: "ffmpeg -i \"input.mp4\" -vf format=yuv420p -vsync 1 \\\n  -c:v hevc_videotoolbox -b:v 5000k -tag:v hvc1 -c:a copy output.mp4"
    )

    // MARK: Archive

    static let archiveQuality = Preset(
        id: "archive_quality",
        name: "Архив (макс. качество)",
        nameEn: "Archive (Max Quality)",
        icon: "archivebox.fill",
        category: .archive,
        shortDescription: "Для важных видео — почти без потерь",
        shortDescriptionEn: "For important videos — near lossless",
        videoCodec: .h265, crf: 20, encoderPreset: .slow,
        fullDescription: "Максимальное качество для долгосрочного хранения.\n\n• CRF 20 — почти неотличимо от оригинала\n• Preset slow — лучшее сжатие при заданном качестве\n• Идеально для видео, которые нельзя восстановить\n\n⚠️ Кодирование занимает значительное время.",
        fullDescriptionEn: "Maximum quality for long-term storage.\n\n• CRF 20 — nearly indistinguishable from original\n• Preset slow — best compression at given quality\n• Ideal for videos you can't recover\n\n⚠️ Encoding takes significant time.",
        compressionRatio: "2–3×", qualityStars: 5,
        timePerHour: "1.5–3 ч", timePerGB: "40–80 мин",
        useCases: ["Свадьбы, выпускные", "Мастер-копии", "Исходники для монтажа", "Невосстановимые записи"],
        useCasesEn: ["Weddings, graduations", "Master copies", "Source files for editing", "Irreplaceable recordings"],
        ffmpegCommand: "ffmpeg -i \"input.mp4\" -vf format=yuv420p -r 30 -vsync 1 \\\n  -c:v libx265 -crf 20 -preset slow -c:a copy output.mp4"
    )

    static let archiveCompact = Preset(
        id: "archive_compact",
        name: "Архив (компактный)",
        nameEn: "Archive (Compact)",
        icon: "tray.full.fill",
        category: .archive,
        shortDescription: "Разумный компромисс размера и качества",
        shortDescriptionEn: "Reasonable balance of size and quality",
        videoCodec: .h265, crf: 26, encoderPreset: .medium,
        audioCodec: .aac, audioBitrate: 128,
        fullDescription: "Оптимизировано для хранения большого архива.\n\n• Хорошее качество при значительном сжатии\n• Аудио перекодируется в AAC 128k\n• Баланс размера и времени кодирования",
        fullDescriptionEn: "Optimized for storing large archives.\n\n• Good quality with significant compression\n• Audio re-encoded to AAC 128k\n• Balance of size and encoding time",
        compressionRatio: "4–6×", qualityStars: 4,
        timePerHour: "35–55 мин", timePerGB: "18–30 мин",
        useCases: ["Большие коллекции видео", "Архив путешествий", "Резервные копии", "Освобождение места"],
        useCasesEn: ["Large video collections", "Travel archives", "Backups", "Freeing up disk space"],
        ffmpegCommand: "ffmpeg -i \"input.mp4\" -vf format=yuv420p -r 30 -vsync 1 \\\n  -c:v libx265 -crf 26 -preset medium \\\n  -c:a aac -b:a 128k output.mp4"
    )

    // MARK: Lectures
    // Note: -tune stillimage removed — incompatible with -vsync 1 in ffmpeg 7.x

    static let lecture = Preset(
        id: "lecture",
        name: "Лекции и презентации",
        nameEn: "Lectures & Presentations",
        icon: "person.wave.2.fill",
        category: .lecture,
        shortDescription: "Оптимизация для статичного контента с речью",
        shortDescriptionEn: "Optimized for static content with speech",
        videoCodec: .h265, crf: 23, encoderPreset: .medium,
        fullDescription: "Для записей с минимальным движением.\n\n• CRF 23 — отличное качество для текста и слайдов\n• Аудио без изменений (голос важен!)\n• Отличный баланс размера и качества",
        fullDescriptionEn: "For recordings with minimal motion.\n\n• CRF 23 — excellent quality for text and slides\n• Audio unchanged (voice matters!)\n• Great balance of size and quality",
        compressionRatio: "4–7×", qualityStars: 4,
        timePerHour: "25–45 мин", timePerGB: "12–22 мин",
        useCases: ["Лекции", "Вебинары", "Скринкасты", "Презентации", "Онлайн-курсы"],
        useCasesEn: ["Lectures", "Webinars", "Screencasts", "Presentations", "Online courses"],
        ffmpegCommand: "ffmpeg -i \"input.mp4\" -vf format=yuv420p -r 30 -vsync 1 \\\n  -c:v libx265 -crf 23 -preset medium -c:a copy output.mp4"
    )

    static let lectureCompact = Preset(
        id: "lecture_compact",
        name: "Лекции (компактные)",
        nameEn: "Lectures (Compact)",
        icon: "doc.zipper",
        category: .lecture,
        shortDescription: "Максимальное сжатие для длинных записей",
        shortDescriptionEn: "Maximum compression for long recordings",
        videoCodec: .h265, crf: 28, encoderPreset: .medium,
        fps: 24,
        audioCodec: .aac, audioBitrate: 96,
        fullDescription: "Для очень длинных записей, где важна экономия места.\n\n• FPS снижен до 24 (незаметно для статичного видео)\n• Аудио 96 kbps — достаточно для речи\n• Агрессивное, но разумное сжатие\n\n⚠️ Не подходит для видео с быстрым движением.",
        fullDescriptionEn: "For very long recordings where space matters.\n\n• FPS reduced to 24 (unnoticeable for static video)\n• Audio 96 kbps — enough for speech\n• Aggressive but reasonable compression\n\n⚠️ Not suitable for videos with fast motion.",
        compressionRatio: "8–12×", qualityStars: 3,
        timePerHour: "20–35 мин", timePerGB: "10–18 мин",
        useCases: ["Многочасовые вебинары", "Записи конференций", "Архив онлайн-курсов", "Zoom-записи"],
        useCasesEn: ["Multi-hour webinars", "Conference recordings", "Online course archives", "Zoom recordings"],
        ffmpegCommand: "ffmpeg -i \"input.mp4\" -vf format=yuv420p -r 24 -vsync 1 \\\n  -c:v libx265 -crf 28 -preset medium \\\n  -c:a aac -b:a 96k output.mp4"
    )

    static let lectureMinimal = Preset(
        id: "lecture_minimal",
        name: "Лекции (минимальный размер)",
        nameEn: "Lectures (Minimum Size)",
        icon: "arrow.down.right.and.arrow.up.left",
        category: .lecture,
        shortDescription: "720p для максимальной экономии места",
        shortDescriptionEn: "720p for maximum space savings",
        videoCodec: .h265, crf: 28, encoderPreset: .medium,
        fps: 24, resolution: .r720p,
        audioCodec: .aac, audioBitrate: 64, monoAudio: true,
        fullDescription: "Максимальная экономия места с приемлемым качеством.\n\n• Разрешение 720p — достаточно для текста и слайдов\n• Моно звук — для записей с одним спикером\n• Минимальный битрейт аудио для речи\n\n⚠️ Подходит только для лекций и презентаций.",
        fullDescriptionEn: "Maximum space savings with acceptable quality.\n\n• 720p resolution — enough for text and slides\n• Mono audio — for single-speaker recordings\n• Minimum audio bitrate for speech\n\n⚠️ Suitable only for lectures and presentations.",
        compressionRatio: "12–20×", qualityStars: 3,
        timePerHour: "15–25 мин", timePerGB: "8–15 мин",
        useCases: ["Огромные архивы лекций", "Когда важен каждый МБ", "Хранение в облаке"],
        useCasesEn: ["Huge lecture archives", "When every MB counts", "Cloud storage"],
        ffmpegCommand: "ffmpeg -i \"input.mp4\" -vf scale=1280:-2,format=yuv420p -r 24 -vsync 1 \\\n  -c:v libx265 -crf 28 -preset medium \\\n  -c:a aac -b:a 64k -ac 1 output.mp4"
    )

    // MARK: Web

    static let youtube = Preset(
        id: "youtube",
        name: "YouTube / Соцсети",
        nameEn: "YouTube / Social",
        icon: "play.rectangle.fill",
        category: .web,
        shortDescription: "Оптимизировано для загрузки на YouTube",
        shortDescriptionEn: "Optimized for uploading to YouTube",
        videoCodec: .h264, crf: 18, encoderPreset: .slow,
        audioCodec: .aac, audioBitrate: 256,
        fullDescription: "Оптимальные настройки для загрузки на YouTube.\n\n• H.264 — YouTube лучше обрабатывает этот кодек\n• Высокое качество (CRF 18) — YouTube перекодирует\n• AAC 256k — хорошее качество звука\n\n💡 YouTube перекодирует видео, поэтому лучше загружать в высоком качестве.",
        fullDescriptionEn: "Optimal settings for uploading to YouTube.\n\n• H.264 — YouTube handles this codec best\n• High quality (CRF 18) — YouTube will re-encode\n• AAC 256k — good audio quality\n\n💡 YouTube re-encodes video, so upload in high quality.",
        compressionRatio: "2–3×", qualityStars: 5,
        timePerHour: "1–2 ч", timePerGB: "30–50 мин",
        useCases: ["YouTube", "Vimeo", "TikTok", "Instagram"],
        useCasesEn: ["YouTube", "Vimeo", "TikTok", "Instagram"],
        ffmpegCommand: "ffmpeg -i \"input.mp4\" -vf format=yuv420p -r 30 -vsync 1 \\\n  -c:v libx264 -crf 18 -preset slow \\\n  -c:a aac -b:a 256k output.mp4"
    )

    static let webVP9 = Preset(
        id: "web_vp9",
        name: "Веб (VP9 + Opus)",
        nameEn: "Web (VP9 + Opus)",
        icon: "globe",
        category: .web,
        shortDescription: "Открытый формат для веб-сайтов",
        shortDescriptionEn: "Open format for websites",
        videoCodec: .vp9, crf: 31, encoderPreset: .medium,
        audioCodec: .opus, audioBitrate: 128,
        fullDescription: "Открытый формат, идеальный для HTML5 видео.\n\n• VP9 — отличное сжатие без патентных ограничений\n• Opus — лучший аудиокодек для веба\n• WebM контейнер — нативная поддержка в браузерах\n\n⚠️ Safari имеет ограниченную поддержку VP9.",
        fullDescriptionEn: "Open format, ideal for HTML5 video.\n\n• VP9 — great compression without patent restrictions\n• Opus — best audio codec for the web\n• WebM container — native browser support\n\n⚠️ Safari has limited VP9 support.",
        compressionRatio: "4–6×", qualityStars: 4,
        timePerHour: "1–2 ч", timePerGB: "30–60 мин",
        useCases: ["Видео на сайте", "Open-source проекты", "Chrome/Firefox"],
        useCasesEn: ["Website video", "Open-source projects", "Chrome/Firefox optimization"],
        ffmpegCommand: "ffmpeg -i \"input.mp4\" -vf format=yuv420p -vsync 1 \\\n  -c:v libvpx-vp9 -crf 31 -b:v 0 -row-mt 1 \\\n  -c:a libopus -b:a 128k output.webm"
    )

    // MARK: Extreme

    static let maximumCompression = Preset(
        id: "maximum_compression",
        name: "Максимальное сжатие (AV1)",
        nameEn: "Maximum Compression (AV1)",
        icon: "arrow.down.circle.fill",
        category: .extreme,
        shortDescription: "Минимальный размер, очень медленно",
        shortDescriptionEn: "Minimum size, very slow",
        videoCodec: .av1, crf: 32, encoderPreset: .medium,
        audioCodec: .opus, audioBitrate: 96,
        fullDescription: "Кодек следующего поколения для минимального размера.\n\n• AV1 — на 30–50% эффективнее H.265\n• Opus — лучший аудиокодек\n• Открытый и бесплатный\n\n⚠️ Очень медленное кодирование!\n⚠️ Ограниченная поддержка старых устройств.\n\n💡 Идеально для архивов на много лет вперёд.",
        fullDescriptionEn: "Next-generation codec for minimum file size.\n\n• AV1 — 30–50% more efficient than H.265\n• Opus — best audio codec\n• Open and free\n\n⚠️ Very slow encoding!\n⚠️ Limited support on old devices.\n\n💡 Ideal for archives that need to last decades.",
        compressionRatio: "6–10×", qualityStars: 4,
        timePerHour: "3–8 ч", timePerGB: "1.5–4 ч",
        useCases: ["Долгосрочное хранение", "Когда размер критичен", "Коллекции фильмов"],
        useCasesEn: ["Long-term storage", "When size is critical", "Movie collections"],
        ffmpegCommand: "ffmpeg -i \"input.mp4\" -vf format=yuv420p -vsync 1 \\\n  -c:v libsvtav1 -crf 32 -preset 6 \\\n  -c:a libopus -b:a 96k output.mp4"
    )

    // MARK: Compatibility

    static let compatible = Preset(
        id: "compatible",
        name: "Максимальная совместимость",
        nameEn: "Maximum Compatibility",
        icon: "checkmark.seal.fill",
        category: .compatibility,
        shortDescription: "Работает на любом устройстве",
        shortDescriptionEn: "Works on any device",
        videoCodec: .h264, crf: 23, encoderPreset: .medium,
        audioCodec: .aac, audioBitrate: 192,
        fullDescription: "Гарантированно работает на любом устройстве.\n\n• H.264 — воспроизводится везде\n• AAC 192k — универсальный аудиокодек\n• Стандартные параметры\n\n💡 Используйте для USB-телевизоров, старых плееров, email.",
        fullDescriptionEn: "Guaranteed to work on any device.\n\n• H.264 — plays everywhere\n• AAC 192k — universal audio codec\n• Standard parameters\n\n💡 Use when video will be played on old TVs, players, or phones.",
        compressionRatio: "2–4×", qualityStars: 4,
        timePerHour: "20–40 мин", timePerGB: "12–22 мин",
        useCases: ["Старые устройства", "USB-флешки для телевизора", "Отправка по email", "Максимальная надёжность"],
        useCasesEn: ["Old devices", "USB drives for TV", "Email attachments", "Maximum reliability"],
        ffmpegCommand: "ffmpeg -i \"input.mp4\" -vf format=yuv420p -r 30 -vsync 1 \\\n  -c:v libx264 -crf 23 -preset medium \\\n  -c:a aac -b:a 192k output.mp4"
    )
}
