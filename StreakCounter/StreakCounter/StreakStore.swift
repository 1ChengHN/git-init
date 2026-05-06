import Foundation

private struct StreakPayload: Codable {
    var streakStartTimeIntervalSince1970: TimeInterval
    var label: String = "戒色"
}

enum StreakStore {
    private static let fileName = "streak.json"

    private static var realHomeURL: URL {
        if let pw = getpwuid(getuid()), let cstr = pw.pointee.pw_dir {
            return URL(fileURLWithPath: String(cString: cstr))
        }
        return FileManager.default.homeDirectoryForCurrentUser
    }

    // App Group sharing is unreliable for ad-hoc-signed extensions on macOS:
    // sandboxd denies I/O on the group container even with the entitlement.
    // The non-sandboxed app target writes into the widget's own sandbox
    // container, which the widget reads with no sandbox check.
    private static var dataURL: URL {
        let dir = realHomeURL
            .appendingPathComponent("Library")
            .appendingPathComponent("Containers")
            .appendingPathComponent("com.local.StreakCounter.widget")
            .appendingPathComponent("Data")
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName)
    }

    private static func load() -> StreakPayload? {
        guard let data = try? Data(contentsOf: dataURL),
              let payload = try? JSONDecoder().decode(StreakPayload.self, from: data) else {
            return nil
        }
        return payload
    }

    private static func save(_ payload: StreakPayload) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        try? data.write(to: dataURL, options: .atomic)
    }

    static var streakStartDate: Date {
        get {
            if let payload = load() {
                return Calendar.current.startOfDay(for: Date(timeIntervalSince1970: payload.streakStartTimeIntervalSince1970))
            }
            let today = Calendar.current.startOfDay(for: Date())
            save(StreakPayload(streakStartTimeIntervalSince1970: today.timeIntervalSince1970))
            return today
        }
        set {
            let normalized = Calendar.current.startOfDay(for: newValue)
            var payload = load() ?? StreakPayload(streakStartTimeIntervalSince1970: normalized.timeIntervalSince1970)
            payload.streakStartTimeIntervalSince1970 = normalized.timeIntervalSince1970
            save(payload)
        }
    }

    static var label: String {
        get { load()?.label ?? "戒色" }
        set {
            var payload = load() ?? StreakPayload(streakStartTimeIntervalSince1970: Date().timeIntervalSince1970)
            payload.label = newValue
            save(payload)
        }
    }

    static func resetStreak() {
        streakStartDate = Date()
    }

    static var daysSinceStreakStart: Int {
        let start = Calendar.current.startOfDay(for: streakStartDate)
        let today = Calendar.current.startOfDay(for: Date())
        let days = Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        return max(0, days)
    }
}
