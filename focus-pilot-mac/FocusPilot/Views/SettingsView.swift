import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var focusTimer: FocusTimer
    @State private var showingStatistics = false
    @State private var showingPermissionAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题
            Text("设置")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 统计分析
                    SettingsSection(title: "数据分析") {
                        SettingsRow(
                            icon: "chart.bar.fill",
                            title: "统计分析",
                            description: "查看您的专注数据和任务完成情况"
                        ) {
                            showingStatistics = true
                        }

                        SettingsRow(
                            icon: "brain.head.profile",
                            title: "AI 生产力报告",
                            description: "获取个性化的工作模式分析和改进建议 (即将推出)"
                        ) {
                            showComingSoonAlert(feature: "AI 生产力报告")
                        }
                    }

                    // 问责与激励
                    SettingsSection(title: "问责与激励") {
                        SettingsRow(
                            icon: "person.2.fill",
                            title: "问责伙伴",
                            description: "邀请朋友或同事成为您的专注伙伴 (即将推出)"
                        ) {
                            showComingSoonAlert(feature: "问责伙伴")
                        }

                        SettingsRow(
                            icon: "gamecontroller.fill",
                            title: "成就系统",
                            description: "通过游戏化元素激励持续专注 (即将推出)"
                        ) {
                            showComingSoonAlert(feature: "成就系统")
                        }

                        SettingsRow(
                            icon: "building.2.fill",
                            title: "虚拟共同工作空间",
                            description: "与他人一起在线专注工作 (即将推出)"
                        ) {
                            showComingSoonAlert(feature: "虚拟共同工作空间")
                        }
                    }

                    // 专注设置
                    SettingsSection(title: "专注模式") {
                        // 系统专注模式设置
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 20)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("系统专注模式")
                                        .font(.headline)
                                    Text("自动启用 macOS 勿扰模式，屏蔽通知干扰")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Circle()
                                        .fill(focusTimer.isSystemFocusEnabled ? Color.green : Color.gray)
                                        .frame(width: 8, height: 8)

                                    Text(focusTimer.isSystemFocusEnabled ? "已启用" : "未启用")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }

                            // 系统专注模式说明
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.caption)

                                    Text("专注时自动隐藏菜单栏和Dock，并尝试启用勿扰模式")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                // 权限设置指导
                                if !focusTimer.isSystemFocusEnabled {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.orange)
                                                .font(.caption)

                                            Text("需要授权才能控制勿扰模式")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                        }

                                        Button("查看设置指导") {
                                            showPermissionInstructions()
                                        }
                                        .font(.caption)
                                        .buttonStyle(.link)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)

                        SettingsRow(
                            icon: "timer",
                            title: "默认专注时长",
                            description: "设置专注会话的默认时长"
                        ) {
                            // TODO: 实现设置功能
                        }

                        SettingsRow(
                            icon: "bell",
                            title: "提醒设置",
                            description: "配置专注完成和休息提醒"
                        ) {
                            // TODO: 实现设置功能
                        }
                    }

                    // 多平台与集成
                    SettingsSection(title: "多平台与集成") {
                        SettingsRow(
                            icon: "iphone",
                            title: "移动端应用",
                            description: "在手机上同步您的任务和专注会话 (即将推出)"
                        ) {
                            showComingSoonAlert(feature: "移动端应用")
                        }

                        SettingsRow(
                            icon: "calendar",
                            title: "日历集成",
                            description: "与 Apple Calendar、Google Calendar 等同步 (即将推出)"
                        ) {
                            showComingSoonAlert(feature: "日历集成")
                        }

                        SettingsRow(
                            icon: "envelope.fill",
                            title: "邮件集成",
                            description: "从邮件中快速创建任务 (即将推出)"
                        ) {
                            showComingSoonAlert(feature: "邮件集成")
                        }
                    }

                    // 社区分享
                    SettingsSection(title: "社区分享") {
                        SettingsRow(
                            icon: "person.3.fill",
                            title: "智囊团",
                            description: "与社区成员分享经验和获取建议 (即将推出)"
                        ) {
                            showComingSoonAlert(feature: "智囊团")
                        }

                        SettingsRow(
                            icon: "square.and.arrow.up",
                            title: "X 平台集成",
                            description: "分享您的专注成果到 X 平台 (即将推出)"
                        ) {
                            showComingSoonAlert(feature: "X 平台集成")
                        }
                    }

                    // 数据管理
                    SettingsSection(title: "数据管理") {
                        SettingsRow(
                            icon: "arrow.clockwise",
                            title: "重置每日推荐",
                            description: "清除今日推荐，重新生成"
                        ) {
                            Task {
                                await taskManager.generateDailyRecommendations()
                            }
                        }
                        
                        SettingsRow(
                            icon: "trash",
                            title: "清除已完成任务",
                            description: "删除所有已完成的任务"
                        ) {
                            taskManager.clearCompletedTasks()
                        }
                    }
                    
                    // 关于
                    SettingsSection(title: "关于") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("FocusPilot")
                                .font(.headline)
                            Text("版本 1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("您的智能专注助手")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingStatistics) {
            StatisticsView()
        }
        .alert("权限设置指导", isPresented: $showingPermissionAlert) {
            Button("打开系统偏好设置") {
                openSystemPreferences()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("要启用勿扰模式控制，请按以下步骤操作：\n\n1. 打开 系统偏好设置\n2. 选择 安全性与隐私\n3. 点击 隐私 标签\n4. 选择左侧的 自动化\n5. 找到 FocusPilot 并勾选 System Events")
        }
    }

    private func showPermissionInstructions() {
        showingPermissionAlert = true
    }

    private func openSystemPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!
        NSWorkspace.shared.open(url)
    }

    private func showComingSoonAlert(feature: String) {
        let alert = NSAlert()
        alert.messageText = "\(feature) - 即将推出"
        alert.informativeText = "这个功能正在开发中，将在未来的版本中推出。感谢您的关注！\n\n我们致力于不断改进 FocusPilot，为您提供更好的专注体验。"
        alert.addButton(withTitle: "了解")
        alert.addButton(withTitle: "关注更新")

        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            // 可以在这里添加关注更新的逻辑，比如打开网站或邮件订阅
            if let url = URL(string: "https://focuspilot.app/updates") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 1) {
                content
            }
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
        .environmentObject(TaskManager())
        .environmentObject(FocusTimer())
}
