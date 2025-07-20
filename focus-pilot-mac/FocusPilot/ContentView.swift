import SwiftUI

struct ContentView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var focusTimer: FocusTimer
    @State private var selectedTab = 0
    @State private var showingDailyStandup = false
    @State private var showingAddTask = false
    @State private var showingOnboarding = false
    
    var body: some View {
        NavigationView {
            // 侧边栏
            VStack(spacing: 0) {
                // 应用标题
                HStack {
                    Image("AppIcon")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .cornerRadius(6)
                    Text("FocusPilot")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding()
                
                Divider()
                
                // 主要导航
                VStack(alignment: .leading, spacing: 8) {
                    NavigationButton(
                        title: "今日重点",
                        icon: "star.fill",
                        isSelected: selectedTab == 0,
                        description: "AI 推荐的重要任务"
                    ) {
                        selectedTab = 0
                    }

                    NavigationButton(
                        title: "专注模式",
                        icon: "timer",
                        isSelected: selectedTab == 1,
                        description: "开始专注工作"
                    ) {
                        selectedTab = 1
                    }

                    NavigationButton(
                        title: "所有任务",
                        icon: "list.bullet",
                        isSelected: selectedTab == 2,
                        description: "管理全部任务"
                    ) {
                        selectedTab = 2
                    }

                    NavigationButton(
                        title: "社区",
                        icon: "person.3.fill",
                        isSelected: selectedTab == 4,
                        description: "智囊团与经验分享"
                    ) {
                        selectedTab = 4
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 16)
                
                Spacer()
                
                // 底部操作按钮
                VStack(spacing: 8) {
                    Button(action: {
                        showingDailyStandup = true
                    }) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                            Text("每日站会")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        showingAddTask = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("添加任务")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // 测试按钮（仅在调试模式下显示）
                    #if DEBUG
                    Button(action: {
                        Task {
                            await taskManager.runAllTests()
                        }
                    }) {
                        HStack {
                            Image(systemName: "testtube.2")
                            Text("运行测试")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    #endif
                }
                .padding()
            }
            .frame(width: 220)
            .background(
                LinearGradient(
                    colors: [
                        Color(NSColor.controlBackgroundColor),
                        Color(NSColor.controlBackgroundColor).opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1)
                    .offset(x: 110), // 右边框
                alignment: .trailing
            )
            
            // 主内容区域
            Group {
                switch selectedTab {
                case 0:
                    TodayFocusView()
                case 1:
                    FocusModeView()
                case 2:
                    AllTasksView()
                case 3:
                    SettingsView()
                case 4:
                    ComingSoonView(feature: "社区功能")
                default:
                    TodayFocusView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $showingDailyStandup) {
            DailyStandupView()
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView()
        }
        .onAppear {
            // 检查是否需要显示用户引导
            checkForOnboarding()
            // 检查是否需要显示每日站会
            checkForDailyStandup()
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusSessionCompleted)) { _ in
            // 专注会话完成后自动切换到今日重点页面
            selectedTab = 0
        }
        .onReceive(NotificationCenter.default.publisher(for: .showAddTask)) { _ in
            // 显示添加任务界面
            showingAddTask = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusSessionStarted)) { _ in
            // 专注会话开始后自动切换到专注模式页面
            selectedTab = 1
        }
    }
    
    private func checkForOnboarding() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        if !hasCompletedOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingOnboarding = true
            }
        }
    }

    private func checkForDailyStandup() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        // 只有完成引导后才显示每日站会
        guard hasCompletedOnboarding else { return }

        let lastStandupDate = UserDefaults.standard.object(forKey: "lastDailyStandup") as? Date
        let today = Calendar.current.startOfDay(for: Date())

        // 检查用户是否启用了自动显示每日站会（默认为false，避免频繁弹出）
        let autoShowStandup = UserDefaults.standard.object(forKey: "autoShowDailyStandup") as? Bool ?? false

        if autoShowStandup && (lastStandupDate == nil || !Calendar.current.isDate(lastStandupDate!, inSameDayAs: today)) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showingDailyStandup = true
            }
        }
    }
}

struct ComingSoonView: View {
    let feature: String

    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue)

            VStack(spacing: 16) {
                Text("\(feature)")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("即将推出")
                    .font(.title2)
                    .foregroundColor(.blue)

                Text("我们正在精心打造这个功能，敬请期待！")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct NavigationButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let description: String?
    let action: () -> Void

    @State private var isHovered = false

    init(title: String, icon: String, isSelected: Bool, description: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.description = description
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // 图标容器
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(iconBackgroundColor)
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(titleColor)

                    if let description = description {
                        Text(description)
                            .font(.system(size: 12))
                            .foregroundColor(descriptionColor)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // 选中指示器
                if isSelected {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(backgroundView)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }

    // MARK: - 计算属性

    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowOffset
            )
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.blue.opacity(0.1)
        } else if isHovered {
            return Color.gray.opacity(0.05)
        } else {
            return Color.clear
        }
    }

    private var borderColor: Color {
        if isSelected {
            return Color.blue.opacity(0.3)
        } else if isHovered {
            return Color.gray.opacity(0.2)
        } else {
            return Color.clear
        }
    }

    private var iconBackgroundColor: Color {
        if isSelected {
            return Color.blue
        } else if isHovered {
            return Color.blue.opacity(0.1)
        } else {
            return Color.gray.opacity(0.1)
        }
    }

    private var iconColor: Color {
        if isSelected {
            return .white
        } else {
            return .blue
        }
    }

    private var titleColor: Color {
        if isSelected {
            return .blue
        } else {
            return .primary
        }
    }

    private var descriptionColor: Color {
        if isSelected {
            return .blue.opacity(0.7)
        } else {
            return .secondary
        }
    }

    private var shadowColor: Color {
        if isSelected {
            return Color.blue.opacity(0.2)
        } else if isHovered {
            return Color.black.opacity(0.05)
        } else {
            return Color.clear
        }
    }

    private var shadowRadius: CGFloat {
        if isSelected {
            return 8
        } else if isHovered {
            return 4
        } else {
            return 0
        }
    }

    private var shadowOffset: CGFloat {
        if isSelected {
            return 2
        } else if isHovered {
            return 1
        } else {
            return 0
        }
    }
}

// 统计分析视图
struct StatisticsView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var focusTimer: FocusTimer

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 标题
                Text("统计分析")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // 任务统计
                VStack(alignment: .leading, spacing: 16) {
                    Text("任务概览")
                        .font(.headline)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        StatCard(title: "总任务数", value: "\(taskManager.tasks.count)", color: .blue)
                        StatCard(title: "已完成", value: "\(taskManager.completedTasks.count)", color: .green)
                        StatCard(title: "进行中", value: "\(taskManager.inProgressTasks.count)", color: .orange)
                        StatCard(title: "待处理", value: "\(taskManager.pendingTasks.count)", color: .gray)
                    }
                }

                // 专注会话统计
                VStack(alignment: .leading, spacing: 16) {
                    Text("专注统计")
                        .font(.headline)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        StatCard(title: "总会话数", value: "\(taskManager.focusSessions.count)", color: .purple)
                        StatCard(title: "今日会话", value: "\(todaySessionsCount)", color: .indigo)
                        StatCard(title: "总专注时长", value: "\(totalFocusTime) 分钟", color: .mint)
                        StatCard(title: "平均时长", value: "\(averageSessionTime) 分钟", color: .teal)
                    }
                }

                // 任务完成趋势（简化版）
                VStack(alignment: .leading, spacing: 16) {
                    Text("最近完成的任务")
                        .font(.headline)

                    if recentCompletedTasks.isEmpty {
                        Text("暂无已完成的任务")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(recentCompletedTasks.prefix(5)) { task in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)

                                VStack(alignment: .leading) {
                                    Text(task.title)
                                        .font(.subheadline)

                                    if let completedAt = task.completedAt {
                                        Text(completedAt, style: .relative)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()

                                PriorityBadge(priority: task.priority)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .padding()
        }
    }

    private var todaySessionsCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return taskManager.focusSessions.filter { session in
            Calendar.current.isDate(session.startTime, inSameDayAs: today)
        }.count
    }

    private var totalFocusTime: Int {
        taskManager.focusSessions.reduce(0) { total, session in
            total + (session.actualDuration ?? session.duration)
        }
    }

    private var averageSessionTime: Int {
        guard !taskManager.focusSessions.isEmpty else { return 0 }
        return totalFocusTime / taskManager.focusSessions.count
    }

    private var recentCompletedTasks: [FocusTask] {
        taskManager.completedTasks.sorted { task1, task2 in
            guard let date1 = task1.completedAt, let date2 = task2.completedAt else { return false }
            return date1 > date2
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// 这些组件已经在TodayFocusView.swift中定义，移除重复定义

#Preview {
    ContentView()
        .environmentObject(TaskManager())
        .environmentObject(FocusTimer())
}
