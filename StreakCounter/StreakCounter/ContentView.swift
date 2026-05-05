import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

struct ContentView: View {
    @State private var days: Int = StreakStore.daysSinceStreakStart
    @State private var showResetConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("戒色天数")
                .font(.title2.weight(.semibold))

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(days)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text("天")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .animation(.default, value: days)

            Text("从 \(formattedStartDate) 起算")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer(minLength: 8)

            Button(role: .destructive) {
                showResetConfirm = true
            } label: {
                Text("记录失败，重新开始")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Text("失败后请点击上方按钮；小组件与 App 共用本地记录，刷新会有短暂延迟。")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            days = StreakStore.daysSinceStreakStart
        }
        .confirmationDialog("确定重新开始计数？", isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("重新开始", role: .destructive) {
                StreakStore.resetStreak()
                days = StreakStore.daysSinceStreakStart
                reloadWidgets()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("将把「开始日」设为今天，天数归零后重新累计。")
        }
    }

    private var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateStyle = .medium
        return formatter.string(from: StreakStore.streakStartDate)
    }

    private func reloadWidgets() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}

#Preview {
    ContentView()
}
