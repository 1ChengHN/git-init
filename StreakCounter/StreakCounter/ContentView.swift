import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var days: Int = StreakStore.daysSinceStreakStart
    @State private var showResetConfirm = false

    // Deep ink palette
    private let ink     = Color(red: 0.02, green: 0.02, blue: 0.06)
    private let card    = Color(red: 0.06, green: 0.05, blue: 0.11)
    private let gold    = Color(red: 0.92, green: 0.72, blue: 0.38)
    private let rose    = Color(red: 0.86, green: 0.42, blue: 0.35)
    private let surface = Color.white.opacity(0.04)

    var body: some View {
        ZStack {
            ink.ignoresSafeArea()

            // Subtle top-light vignette
            EllipticalGradient(
                colors: [Color.white.opacity(0.03), .clear],
                center: .top,
                startRadiusFraction: 0,
                endRadiusFraction: 0.9
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Giant hero number
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(days)")
                        .font(.system(size: 128, weight: .ultraLight, design: .serif))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())

                    VStack(alignment: .leading, spacing: 0) {
                        Text("天")
                            .font(.system(size: 24, weight: .light, design: .serif))
                            .foregroundStyle(Color.white.opacity(0.3))
                            .padding(.bottom, 2)
                        Text("已坚持")
                            .font(.system(size: 11, weight: .regular, design: .serif))
                            .foregroundStyle(Color.white.opacity(0.2))
                            .tracking(4)
                    }
                    .padding(.leading, 8)
                    .padding(.bottom, 8)
                }

                Spacer().frame(height: 28)

                // MARK: - Elegant divider
                Rectangle()
                    .fill(
                        LinearGradient(colors: [.clear, gold.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: 200, height: 0.5)

                Spacer().frame(height: 24)

                // MARK: - Motto
                Text(motto)
                    .font(.system(size: 14, weight: .light, design: .serif))
                    .foregroundStyle(Color.white.opacity(0.5))
                    .tracking(2)

                Spacer().frame(height: 6)

                Text(formattedStartDate)
                    .font(.system(size: 11, weight: .light, design: .serif))
                    .foregroundStyle(Color.white.opacity(0.18))

                Spacer().frame(height: 40)

                // MARK: - Reset (barely there)
                Button {
                    showResetConfirm = true
                } label: {
                    Text("重新开始")
                        .font(.system(size: 10, weight: .regular, design: .serif))
                        .tracking(3)
                        .foregroundColor(Color.white.opacity(0.2))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 1)
                                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                        )
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .frame(width: 340)
            .padding(.top, 40)
            .padding(.bottom, 20)
        }
        .frame(width: 460, height: 560)
        .fixedSize()
        .onAppear {
            days = StreakStore.daysSinceStreakStart
            reloadWidgets()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                days = StreakStore.daysSinceStreakStart
                reloadWidgets()
            }
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

    private var motto: String {
        if days >= 90 { return "九十日，大功告成" }
        if days >= 60 { return "六十日，已成习惯" }
        if days >= 30 { return "三十日，初具成效" }
        if days >= 14 { return "十四日，渐入佳境" }
        if days >= 7  { return "七日坚守，继续加油" }
        if days >= 3  { return "三日之约，不可松懈" }
        return "千里之行，始于足下"
    }

    private var formattedStartDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "yyyy年M月d日"
        return "自\(f.string(from: StreakStore.streakStartDate))起"
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
