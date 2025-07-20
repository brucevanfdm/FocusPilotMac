import Foundation
import Combine
import AppKit
import UserNotifications
import AppKit

class FocusTimer: ObservableObject {
    @Published var isRunning = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    @Published var currentTask: FocusTask?
    @Published var sessionStartTime: Date?
    @Published var isSystemFocusEnabled = false

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // 预设的专注时长（分钟）
    let presetDurations = [15, 25, 45, 60, 90]

    // 暴露系统专注管理器
    // var systemFocus: SystemFocusManager {
    //     return systemFocusManager
    // }
    
    // MARK: - 计时器控制
    
    func startTimer(for task: FocusTask, duration: Int) {
        print("⏰ 开始专注会话: \(task.title) - \(duration)分钟")

        currentTask = task
        totalTime = TimeInterval(duration * 60) // 转换为秒
        timeRemaining = totalTime
        sessionStartTime = Date()
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }

        // 启用系统专注模式
        enableSystemFocus(for: task, duration: duration)

        // 发送专注会话开始通知
        NotificationCenter.default.post(name: .focusSessionStarted, object: self)

        print("✅ 专注计时器已启动")
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resumeTimer() {
        guard !isRunning && timeRemaining > 0 else { return }
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        timeRemaining = 0
        totalTime = 0
        currentTask = nil
        sessionStartTime = nil

        // 禁用系统专注模式
        disableSystemFocus()
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        timeRemaining = totalTime
    }
    
    private func tick() {
        guard timeRemaining > 0 else {
            completeSession()
            return
        }
        
        timeRemaining -= 1
    }
    
    private func completeSession() {
        isRunning = false
        timer?.invalidate()
        timer = nil

        // 禁用系统专注模式
        disableSystemFocus()

        // 发送完成通知
        NotificationCenter.default.post(name: .focusSessionCompleted, object: self)

        // 播放完成提示音
        playCompletionSound()
    }
    
    // MARK: - 时间格式化
    
    var formattedTimeRemaining: String {
        formatTime(timeRemaining)
    }
    
    var formattedTotalTime: String {
        formatTime(totalTime)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - 进度计算
    
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return (totalTime - timeRemaining) / totalTime
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    // MARK: - 建议时长
    
    func suggestedDuration(for task: FocusTask) -> Int {
        // 根据任务类型和复杂度建议时长
        if let estimatedDuration = task.estimatedDuration {
            return min(estimatedDuration, 90) // 最长90分钟
        }
        
        // 根据任务标题关键词判断
        let title = task.title.lowercased()
        
        if title.contains("会议") || title.contains("电话") || title.contains("沟通") {
            return 30
        } else if title.contains("编程") || title.contains("开发") || title.contains("代码") {
            return 45
        } else if title.contains("写作") || title.contains("文档") || title.contains("报告") {
            return 60
        } else if title.contains("学习") || title.contains("研究") || title.contains("阅读") {
            return 25
        } else {
            return 25 // 默认番茄钟时长
        }
    }
    
    // MARK: - 统计信息
    
    var elapsedTime: TimeInterval {
        totalTime - timeRemaining
    }
    
    var elapsedMinutes: Int {
        Int(elapsedTime) / 60
    }
    
    // MARK: - 通知和提醒
    
    private func playCompletionSound() {
        // 在实际应用中，这里可以播放系统提示音
        NSSound.beep()
    }
    
    func scheduleBreakReminder() {
        // 可以在这里实现休息提醒功能
        DispatchQueue.main.asyncAfter(deadline: .now() + 5 * 60) { // 5分钟后提醒
            self.showBreakReminder()
        }
    }
    
    private func showBreakReminder() {
        // 显示休息提醒
        NotificationCenter.default.post(name: .breakReminderTriggered, object: self)
    }
    
    // MARK: - 会话历史
    
    func getSessionDuration() -> Int? {
        guard let startTime = sessionStartTime else { return nil }
        let duration = Date().timeIntervalSince(startTime)
        return Int(duration / 60) // 返回分钟数
    }
    
    // MARK: - 系统专注模式

    /// 启用系统专注模式
    private func enableSystemFocus(for task: FocusTask, duration: Int) {
        print("🔕 启用系统专注模式...")

        // 1. 设置应用为全屏模式（隐藏菜单栏和Dock）
        DispatchQueue.main.async {
            NSApp.presentationOptions = [.hideDock, .hideMenuBar]
            self.isSystemFocusEnabled = true
        }

        // 2. 发送专注开始通知
        sendFocusNotification(
            title: "专注会话已开始",
            body: "正在专注：\(task.title)\n时长：\(duration) 分钟\n\n已启用专注环境"
        )

        // 3. 尝试设置勿扰模式（通过AppleScript）
        setDoNotDisturb(enabled: true)

        print("✅ 系统专注模式已启用")
    }

    /// 禁用系统专注模式
    private func disableSystemFocus() {
        print("🔔 禁用系统专注模式...")

        // 1. 恢复正常显示模式
        DispatchQueue.main.async {
            NSApp.presentationOptions = []
            self.isSystemFocusEnabled = false
        }

        // 2. 发送专注结束通知
        sendFocusNotification(
            title: "专注会话结束",
            body: "恭喜完成专注会话！\n专注环境已恢复正常"
        )

        // 3. 取消勿扰模式
        setDoNotDisturb(enabled: false)

        print("✅ 系统专注模式已禁用")
    }

    /// 设置勿扰模式
    private func setDoNotDisturb(enabled: Bool) {
        // 方法1: 尝试使用现代的 Focus 模式 API (macOS 12+)
        if #available(macOS 12.0, *) {
            setFocusModeUsingAPI(enabled: enabled)
        } else {
            // 方法2: 回退到 AppleScript 方式
            setDoNotDisturbUsingAppleScript(enabled: enabled)
        }
    }

    /// 使用现代 Focus API 设置专注模式 (macOS 12+)
    @available(macOS 12.0, *)
    private func setFocusModeUsingAPI(enabled: Bool) {
        // 注意: 这个方法需要用户手动在系统设置中配置 Focus 模式
        // 我们可以提供指导，但无法直接控制
        print(enabled ? "🔕 建议启用系统专注模式" : "🔔 建议关闭系统专注模式")

        // 显示用户指导通知
        let message = enabled ?
            "建议手动启用 macOS 专注模式以获得最佳体验" :
            "可以关闭 macOS 专注模式了"

        showFocusModeGuidance(message: message)
    }

    /// 使用 AppleScript 设置勿扰模式 (兼容旧版本)
    private func setDoNotDisturbUsingAppleScript(enabled: Bool) {
        let script = """
        tell application "System Events"
            try
                if \(enabled ? "true" : "false") then
                    do shell script "defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean true"
                    do shell script "killall NotificationCenter"
                else
                    do shell script "defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean false"
                    do shell script "killall NotificationCenter"
                end if
            on error errMsg
                log "无法设置勿扰模式: " & errMsg
            end try
        end tell
        """

        DispatchQueue.global(qos: .userInitiated).async {
            let appleScript = NSAppleScript(source: script)
            var error: NSDictionary?
            appleScript?.executeAndReturnError(&error)

            if let error = error {
                print("⚠️ 设置勿扰模式失败: \(error)")

                // 如果是权限问题，显示用户指导
                if let errorMessage = error["NSAppleScriptErrorMessage"] as? String,
                   errorMessage.contains("Not authorized") {
                    DispatchQueue.main.async {
                        self.showPermissionGuidance()
                    }
                }
            } else {
                print(enabled ? "✅ 勿扰模式已启用" : "✅ 勿扰模式已关闭")
            }
        }
    }

    /// 显示权限设置指导
    private func showPermissionGuidance() {
        let content = UNMutableNotificationContent()
        content.title = "需要授权"
        content.body = "请在 系统偏好设置 → 安全性与隐私 → 隐私 → 自动化 中，允许 FocusPilot 控制 System Events"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "permission-guidance-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("⚠️ 发送权限指导通知失败: \(error)")
            }
        }
    }

    /// 显示专注模式使用指导
    private func showFocusModeGuidance(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "专注模式提示"
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "focus-guidance-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("⚠️ 发送专注模式指导通知失败: \(error)")
            }
        }
    }

    /// 发送系统通知
    private func sendFocusNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "focus-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("⚠️ 发送通知失败: \(error)")
            }
        }
    }

    // MARK: - 清理

    deinit {
        timer?.invalidate()
        // 确保退出时恢复正常状态
        if isSystemFocusEnabled {
            disableSystemFocus()
        }
    }
}

// MARK: - 通知名称

extension Notification.Name {
    static let focusSessionCompleted = Notification.Name("focusSessionCompleted")
    static let focusSessionStarted = Notification.Name("focusSessionStarted")
    static let breakReminderTriggered = Notification.Name("breakReminderTriggered")
}

// MARK: - 专注模式状态

enum FocusMode {
    case focus    // 专注时间
    case shortBreak // 短休息
    case longBreak  // 长休息
    
    var displayName: String {
        switch self {
        case .focus: return "专注时间"
        case .shortBreak: return "短休息"
        case .longBreak: return "长休息"
        }
    }
    
    var defaultDuration: Int {
        switch self {
        case .focus: return 25
        case .shortBreak: return 5
        case .longBreak: return 15
        }
    }
}
