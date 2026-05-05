import Foundation

/// 主应用与小组件通过同一文件共享「开始日」（非沙盒下使用 Application Support）
private struct StreakPayload: Codable {
    var streakStartTimeIntervalSince1970: TimeInterval
}

enum StreakStore {
    private static let streakFileName = "streak.json"

    private static var persistenceURL: URL? {
        guard let applicationSupportRoot = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let streakFolder = applicationSupportRoot.appendingPathComponent("StreakCounter", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: streakFolder, withIntermediateDirectories: true)
        } catch {
            return nil
        }
        return streakFolder.appendingPathComponent(streakFileName)
    }

    private static func loadPayload() -> StreakPayload? {
        guard let url = persistenceURL else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(StreakPayload.self, from: data)
    }

    private static func savePayload(_ payload: StreakPayload) {
        guard let url = persistenceURL else { return }
        do {
            let data = try JSONEncoder().encode(payload)
            try data.write(to: url, options: .atomic)
        } catch {
            /* 磁盘满或权限问题时静默失败，界面仍显示内存中的逻辑日 */
        }
    }

    /// 当前周期开始日（未持久化过则记为「今天」的开始）
    static var streakStartDate: Date {
        get {
            if let payload = loadPayload() {
                let stored = Date(timeIntervalSince1970: payload.streakStartTimeIntervalSince1970)
                return calendarStartOfDay(from: stored)
            }
            let start = calendarStartOfDay(from: Date())
            savePayload(StreakPayload(streakStartTimeIntervalSince1970: start.timeIntervalSince1970))
            return start
        }
        set {
            let normalized = calendarStartOfDay(from: newValue)
            savePayload(StreakPayload(streakStartTimeIntervalSince1970: normalized.timeIntervalSince1970))
        }
    }

    static func resetStreak() {
        streakStartDate = Date()
    }

    static var daysSinceStreakStart: Int {
        let start = calendarStartOfDay(from: streakStartDate)
        let today = calendarStartOfDay(from: Date())
        let dayCount = Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        return max(0, dayCount)
    }

    private static func calendarStartOfDay(from date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}
