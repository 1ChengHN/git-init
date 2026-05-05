import SwiftUI
import WidgetKit

private struct StreakEntry: TimelineEntry {
    let date: Date
    let days: Int
}

private struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), days: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        let entry = StreakEntry(date: Date(), days: StreakStore.daysSinceStreakStart)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let now = Date()
        let entry = StreakEntry(date: now, days: StreakStore.daysSinceStreakStart)
        let nextMidnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime,
            direction: .forward
        ) ?? now.addingTimeInterval(86_400)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }
}

private struct StreakCounterWidgetEntryView: View {
    var entry: StreakEntry

    var body: some View {
        VStack(spacing: 6) {
            Text("戒色")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(entry.days)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .monospacedDigit()
                .widgetAccentable()
            Text("天")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct StreakCounterWidget: Widget {
    let kind: String = "StreakCounterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakCounterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("戒色天数")
        .description("显示已连续天数；在「戒色天数」App 中可重置。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
