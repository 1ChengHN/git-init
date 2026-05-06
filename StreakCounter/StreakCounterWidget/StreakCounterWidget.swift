import SwiftUI
import WidgetKit

// MARK: - Timeline Entry

private struct StreakEntry: TimelineEntry {
    let date: Date
    let days: Int
    let label: String
}

// MARK: - Provider

private struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), days: 7, label: "戒色")
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        let entry = StreakEntry(
            date: Date(),
            days: StreakStore.daysSinceStreakStart,
            label: StreakStore.label
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let cal = Calendar.current
        let now = Date()
        let label = StreakStore.label
        let start = cal.startOfDay(for: StreakStore.streakStartDate)
        let todayStart = cal.startOfDay(for: now)

        func days(at date: Date) -> Int {
            max(0, cal.dateComponents([.day], from: start, to: date).day ?? 0)
        }

        // Entry for "now" so the widget renders immediately, plus one entry at
        // each upcoming midnight so the count flips at exactly 00:00 without
        // waiting for WidgetKit to re-request a timeline.
        var entries: [StreakEntry] = [
            StreakEntry(date: now, days: days(at: todayStart), label: label)
        ]
        for offset in 1...7 {
            guard let midnight = cal.date(byAdding: .day, value: offset, to: todayStart) else { continue }
            entries.append(StreakEntry(date: midnight, days: days(at: midnight), label: label))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

// MARK: - Palette

private struct C {
    static let bg     = Color(red: 0.02, green: 0.02, blue: 0.06)
    static let bg2    = Color(red: 0.05, green: 0.04, blue: 0.10)
    static let gold   = Color(red: 0.92, green: 0.72, blue: 0.38)
    static let rose   = Color(red: 0.86, green: 0.42, blue: 0.35)
    static let text   = Color.white
    static let dim    = Color.white.opacity(0.30)
    static let faint  = Color.white.opacity(0.15)
}

// MARK: - Small Widget

private struct SmallWidgetView: View {
    let entry: StreakEntry

    var body: some View {
        VStack(spacing: 0) {
            Text(entry.label)
                .font(.system(size: 10, weight: .light, design: .serif))
                .foregroundStyle(C.gold)
                .tracking(4)
                .padding(.bottom, 4)
            Text("\(entry.days)")
                .font(.system(size: 46, weight: .ultraLight, design: .serif))
                .monospacedDigit()
                .foregroundStyle(C.text)
            Text("天")
                .font(.system(size: 11, weight: .light, design: .serif))
                .foregroundStyle(C.dim)
                .tracking(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(
            LinearGradient(colors: [C.bg, C.bg2], startPoint: .top, endPoint: .bottom),
            for: .widget
        )
    }
}

// MARK: - Medium Widget

private struct MediumWidgetView: View {
    let entry: StreakEntry

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(entry.label)
                    .font(.system(size: 11, weight: .light, design: .serif))
                    .foregroundStyle(C.gold)
                    .tracking(3)
                    .padding(.bottom, 6)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(entry.days)")
                        .font(.system(size: 56, weight: .ultraLight, design: .serif))
                        .monospacedDigit()
                        .foregroundStyle(C.text)
                    Text("天")
                        .font(.system(size: 14, weight: .light, design: .serif))
                        .foregroundStyle(C.dim)
                }

                Spacer().frame(height: 8)

                Text(motto)
                    .font(.system(size: 10, weight: .light, design: .serif))
                    .foregroundStyle(C.faint)
                    .tracking(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(
            LinearGradient(colors: [C.bg, C.bg2], startPoint: .topLeading, endPoint: .bottomTrailing),
            for: .widget
        )
    }

    private var motto: String {
        if entry.days >= 90 { return "九十日，大功告成" }
        if entry.days >= 60 { return "六十日，已成习惯" }
        if entry.days >= 30 { return "三十日，初具成效" }
        if entry.days >= 14 { return "十四日，渐入佳境" }
        if entry.days >= 7  { return "七日坚守，继续加油" }
        if entry.days >= 3  { return "三日之约，不可松懈" }
        return "千里之行，始于足下"
    }
}

// MARK: - Large Widget

private struct LargeWidgetView: View {
    let entry: StreakEntry

    var body: some View {
        VStack(spacing: 0) {
            // Top label
            HStack {
                Text(entry.label)
                    .font(.system(size: 14, weight: .light, design: .serif))
                    .foregroundStyle(C.gold)
                    .tracking(6)
                Spacer()
            }

            Spacer()

            // Huge number
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(entry.days)")
                    .font(.system(size: 110, weight: .ultraLight, design: .serif))
                    .monospacedDigit()
                    .foregroundStyle(C.text)
                Text("天")
                    .font(.system(size: 20, weight: .light, design: .serif))
                    .foregroundStyle(C.dim)
                    .padding(.bottom, 10)
            }

            // Divider
            Rectangle()
                .fill(
                    LinearGradient(colors: [.clear, C.gold.opacity(0.5), .clear], startPoint: .leading, endPoint: .trailing)
                )
                .frame(height: 0.5)
                .padding(.vertical, 14)

            // Motto
            Text(motto)
                .font(.system(size: 13, weight: .light, design: .serif))
                .foregroundStyle(C.dim)
                .tracking(2)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(
            LinearGradient(colors: [C.bg, C.bg2], startPoint: .topLeading, endPoint: .bottomTrailing),
            for: .widget
        )
    }

    private var motto: String {
        if entry.days >= 90 { return "九十日，大功告成" }
        if entry.days >= 60 { return "六十日，已成习惯" }
        if entry.days >= 30 { return "三十日，初具成效" }
        if entry.days >= 14 { return "十四日，渐入佳境" }
        if entry.days >= 7  { return "七日坚守，继续加油" }
        if entry.days >= 3  { return "三日之约，不可松懈" }
        return "千里之行，始于足下"
    }
}

// MARK: - Wrapper

private struct StreakEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: StreakEntry

    var body: some View {
        switch family {
        case .systemMedium:  MediumWidgetView(entry: entry)
        case .systemLarge:   LargeWidgetView(entry: entry)
        default:             SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget

struct StreakCounterWidget: Widget {
    let kind: String = "StreakCounterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakEntryView(entry: entry)
        }
        .configurationDisplayName("坚持天数")
        .description("在桌面显示你的坚持天数，每日自动更新。")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Small", as: .systemSmall) {
    StreakCounterWidget()
} timeline: {
    StreakEntry(date: Date(), days: 7, label: "戒色")
    StreakEntry(date: Date(), days: 128, label: "戒色")
}

#Preview("Medium", as: .systemMedium) {
    StreakCounterWidget()
} timeline: {
    StreakEntry(date: Date(), days: 7, label: "戒色")
}

#Preview("Large", as: .systemLarge) {
    StreakCounterWidget()
} timeline: {
    StreakEntry(date: Date(), days: 128, label: "戒色")
}
#endif
