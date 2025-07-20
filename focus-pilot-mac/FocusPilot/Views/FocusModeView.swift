import SwiftUI

struct FocusModeView: View {
    @EnvironmentObject var focusTimer: FocusTimer
    @EnvironmentObject var taskManager: TaskManager
    @State private var selectedTask: FocusTask?
    @State private var selectedDuration = 25
    @State private var showingTaskPicker = false
    @State private var isStarting = false
    @State private var showingStartConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            if focusTimer.isRunning || focusTimer.timeRemaining > 0 {
                // 专注模式界面
                FocusSessionView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                // 选择任务和时长界面
                FocusSetupView(
                    selectedTask: $selectedTask,
                    selectedDuration: $selectedDuration,
                    showingTaskPicker: $showingTaskPicker,
                    isStarting: $isStarting,
                    showingStartConfirmation: $showingStartConfirmation
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: focusTimer.isRunning)
        .animation(.easeInOut(duration: 0.5), value: focusTimer.timeRemaining > 0)
    }
}

struct FocusSetupView: View {
    @EnvironmentObject var focusTimer: FocusTimer
    @EnvironmentObject var taskManager: TaskManager
    @Binding var selectedTask: FocusTask?
    @Binding var selectedDuration: Int
    @Binding var showingTaskPicker: Bool
    @Binding var isStarting: Bool
    @Binding var showingStartConfirmation: Bool

    var body: some View {
        VStack(spacing: 40) {
            headerSection
            taskSelectionSection
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("开始专注")
                .font(.title)
                .fontWeight(.bold)

            if selectedTask == nil {
                Text("选择一个任务，立即进入专注状态")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("准备好了吗？让我们开始专注工作")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var taskSelectionSection: some View {
        VStack(spacing: 20) {
            if let task = selectedTask {
                selectedTaskView(task: task)
            } else {
                noTaskSelectedView
            }
        }
    }

    private func selectedTaskView(task: FocusTask) -> some View {
        VStack(spacing: 16) {
            Text("当前任务")
                .font(.headline)
                .foregroundColor(.secondary)

            SelectedTaskCard(task: task) {
                showingTaskPicker = true
            }

            durationSelectionView
            startButton
        }
    }

    private var durationSelectionView: some View {
        VStack(spacing: 12) {
            Text("选择专注时长")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach([15, 25, 45, 60], id: \.self) { duration in
                    Button("\(duration)分钟") {
                        selectedDuration = duration
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(selectedDuration == duration ? Color.blue : Color.clear)
                    .foregroundColor(selectedDuration == duration ? .white : .primary)
                    .cornerRadius(6)

                }
            }
        }
    }

    private var startButton: some View {
        Button(action: {
            if let task = selectedTask {
                showingStartConfirmation = true
            }
        }) {
            HStack(spacing: 12) {
                if isStarting {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(isStarting ? "启动中..." : "开始专注 (\(selectedDuration)分钟)")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .foregroundColor(.white)
            .scaleEffect(isStarting ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isStarting)
        }
        .disabled(isStarting)
        .alert("开始专注会话", isPresented: $showingStartConfirmation) {
            Button("取消", role: .cancel) { }
            Button("开始") {
                startFocusSession()
            }
        } message: {
            if let task = selectedTask {
                Text("准备开始 \(selectedDuration) 分钟的专注会话\n\n任务：\(task.title)")
            }
        }
    }

    private func startFocusSession() {
        guard let task = selectedTask else { return }

        isStarting = true

        // 播放启动音效
        NSSound(named: "Glass")?.play()

        // 添加启动延迟以显示反馈
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            focusTimer.startTimer(for: task, duration: selectedDuration)
            taskManager.startFocusSession(for: task, duration: selectedDuration)

            // 重置状态
            isStarting = false

            // 播放确认音效
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                NSSound(named: "Tink")?.play()
            }
        }
    }

    private var noTaskSelectedView: some View {
        VStack(spacing: 20) {
            if !taskManager.todayRecommendedTasks.isEmpty {
                VStack(spacing: 12) {
                    Text("今日推荐任务")
                        .font(.headline)

                    LazyVStack(spacing: 8) {
                        ForEach(taskManager.todayRecommendedTasks.prefix(3)) { task in
                            QuickTaskButton(task: task) {
                                selectedTask = task
                                selectedDuration = focusTimer.suggestedDuration(for: task)
                            }
                        }
                    }
                }

                Text("或")
                    .foregroundColor(.secondary)
            }

            Button("选择其他任务") {
                showingTaskPicker = true
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: 500)
        .sheet(isPresented: $showingTaskPicker) {
            TaskPickerView(selectedTask: $selectedTask)
        }
        .onAppear {
            // 自动选择今日推荐的第一个任务
            if selectedTask == nil && !taskManager.todayRecommendedTasks.isEmpty {
                selectedTask = taskManager.todayRecommendedTasks.first
                if let task = selectedTask {
                    selectedDuration = focusTimer.suggestedDuration(for: task)
                }
            }
        }
    }
}

struct FocusSessionView: View {
    @EnvironmentObject var focusTimer: FocusTimer
    @EnvironmentObject var taskManager: TaskManager
    @State private var showingEndSessionAlert = false
    @State private var pulseAnimation = false
    
    var body: some View {
        HStack(spacing: 40) {
            // 左侧区域 - 任务信息和控制
            VStack(alignment: .leading, spacing: 24) {
                Spacer()

                // 当前任务信息
                if let task = focusTimer.currentTask {
                    VStack(alignment: .leading, spacing: 20) {
                        // 状态指示器
                        HStack(spacing: 12) {
                            Circle()
                                .fill(focusTimer.isRunning ? Color.green : Color.orange)
                                .frame(width: 12, height: 12)
                                .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseAnimation)

                            Text(focusTimer.isRunning ? "正在专注" : "已暂停")
                                .font(.headline)
                                .foregroundColor(focusTimer.isRunning ? .green : .orange)
                        }

                        // 任务信息卡片
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("当前任务")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)

                                Text(task.title)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .lineLimit(3)
                            }

                            if let description = task.description, !description.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("任务描述")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)

                                    Text(description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .lineLimit(4)
                                }
                            }

                            HStack {
                                Text("优先级")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)

                                Spacer()

                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(priorityColor(task.priority))
                                        .frame(width: 8, height: 8)
                                    Text(task.priority.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(priorityColor(task.priority))
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(NSColor.controlBackgroundColor))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                    }
                }


                Spacer()

                // 控制按钮
                VStack(spacing: 12) {
                    if focusTimer.isRunning {
                        Button(action: {
                            focusTimer.pauseTimer()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "pause.fill")
                                Text("暂停")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)

                    } else if focusTimer.timeRemaining > 0 {
                        Button(action: {
                            focusTimer.resumeTimer()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                Text("继续")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }

                    HStack(spacing: 12) {
                        Button(action: {
                            showingEndSessionAlert = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "stop.fill")
                                Text("结束")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            focusTimer.resetTimer()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.clockwise")
                                Text("重置")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()
            }
            .frame(maxWidth: 400)
            .padding(.horizontal, 32)

            // 右侧区域 - 计时器显示
            VStack(spacing: 32) {
                Spacer()

                // 主计时器
                VStack(spacing: 20) {
                    ZStack {
                        // 背景圆环
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 18)
                            .frame(width: 280, height: 280)

                        // 进度圆环
                        Circle()
                            .trim(from: 0, to: focusTimer.progress)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 18, lineCap: .round)
                            )
                            .frame(width: 280, height: 280)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: focusTimer.progress)
                            .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 0)

                        // 内部区域
                        Circle()
                            .fill(Color(NSColor.windowBackgroundColor))
                            .frame(width: 240, height: 240)
                            .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)

                        // 时间显示
                        VStack(spacing: 12) {
                            Text(focusTimer.formattedTimeRemaining)
                                .font(.system(size: 48, weight: .bold, design: .monospaced))
                                .foregroundColor(.primary)
                                .scaleEffect(pulseAnimation && focusTimer.timeRemaining <= 60 ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: pulseAnimation && focusTimer.timeRemaining <= 60)

                            Text("\(focusTimer.progressPercentage)% 完成")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                        }
                    }

                    // 预计完成时间
                    if let endTime = estimatedEndTime {
                        Text("预计 \(endTime) 完成")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // 底部状态
                VStack(spacing: 16) {
                    // 系统专注状态
                    HStack(spacing: 12) {
                        Image(systemName: focusTimer.isSystemFocusEnabled ? "moon.fill" : "moon")
                            .foregroundColor(focusTimer.isSystemFocusEnabled ? .blue : .gray)
                            .font(.system(size: 18))

                        Text(focusTimer.isSystemFocusEnabled ? "系统专注模式已启用" : "系统专注模式未启用")
                            .font(.subheadline)
                            .foregroundColor(focusTimer.isSystemFocusEnabled ? .blue : .secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(focusTimer.isSystemFocusEnabled ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                    )

                    // 虚拟共同工作空间预览
                    Button(action: {
                        showComingSoonAlert(feature: "虚拟共同工作空间")
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.green)
                            Text("加入虚拟工作空间")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green.opacity(0.1))
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .help("与他人一起在线专注工作")

                    // 专注提示
                    Text("保持专注，远离干扰")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .frame(maxWidth: 400)
            .padding(.horizontal, 32)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .alert("结束专注会话", isPresented: $showingEndSessionAlert) {
            Button("取消", role: .cancel) { }
            Button("结束") {
                completeSession()
            }
        } message: {
            Text("确定要结束当前的专注会话吗？")
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusSessionCompleted)) { _ in
            showSessionCompletedAlert()
        }
        .onAppear {
            // 启动动画
            pulseAnimation = true
        }
        .onDisappear {
            pulseAnimation = false
        }
    }

    // 计算预计完成时间
    private var estimatedEndTime: String? {
        guard focusTimer.timeRemaining > 0 else { return nil }
        let endTime = Date().addingTimeInterval(focusTimer.timeRemaining)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: endTime)
    }

    // 优先级颜色
    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }

    private func completeSession() {
        if let sessionDuration = focusTimer.getSessionDuration(),
           let currentTask = focusTimer.currentTask {
            
            // 更新任务的实际时长
            var updatedTask = currentTask
            updatedTask.actualDuration = (updatedTask.actualDuration ?? 0) + sessionDuration
            taskManager.updateTask(updatedTask)
        }
        
        focusTimer.stopTimer()
    }
    
    private func showSessionCompletedAlert() {
        let alert = NSAlert()
        alert.messageText = "专注会话完成！"
        alert.informativeText = "恭喜您完成了一个专注会话。建议休息5-10分钟后继续工作。"
        alert.addButton(withTitle: "好的")
        alert.runModal()

        focusTimer.scheduleBreakReminder()
    }

    private func showComingSoonAlert(feature: String) {
        let alert = NSAlert()
        alert.messageText = "\(feature) - 即将推出"
        alert.informativeText = "这个功能将为您提供更丰富的专注体验，敬请期待！"
        alert.addButton(withTitle: "了解")
        alert.runModal()
    }
}

struct SelectedTaskCard: View {
    let task: FocusTask
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    if let description = task.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        PriorityBadge(priority: task.priority)
                        
                        if !task.subtasks.isEmpty {
                            Text("\(task.subtasks.filter { $0.isCompleted }.count)/\(task.subtasks.count) 子任务")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TaskPickerView: View {
    @EnvironmentObject var taskManager: TaskManager
    @Binding var selectedTask: FocusTask?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("选择任务")
                    .font(.headline)
                
                Spacer()
                
                Button("取消") {
                    dismiss()
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    // 今日推荐任务
                    if !taskManager.todayRecommendedTasks.isEmpty {
                        Section {
                            ForEach(taskManager.todayRecommendedTasks) { task in
                                TaskPickerRow(
                                    task: task,
                                    isSelected: selectedTask?.id == task.id,
                                    isRecommended: true
                                ) {
                                    selectedTask = task
                                    dismiss()
                                }
                            }
                        } header: {
                            HStack {
                                Text("今日推荐")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                        }
                    }
                    
                    // 其他待办任务
                    let otherTasks = taskManager.pendingTasks.filter { task in
                        !taskManager.todayRecommendedTasks.contains { $0.id == task.id }
                    }
                    
                    if !otherTasks.isEmpty {
                        Section {
                            ForEach(otherTasks) { task in
                                TaskPickerRow(
                                    task: task,
                                    isSelected: selectedTask?.id == task.id,
                                    isRecommended: false
                                ) {
                                    selectedTask = task
                                    dismiss()
                                }
                            }
                        } header: {
                            HStack {
                                Text("其他任务")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                        }
                    }
                }
            }
        }
        .frame(width: 400, height: 500)
    }
}

struct TaskPickerRow: View {
    let task: FocusTask
    let isSelected: Bool
    let isRecommended: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(task.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        if isRecommended {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        PriorityBadge(priority: task.priority)
                        
                        if let dueDate = task.dueDate {
                            Text(dueDate, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

struct QuickTaskButton: View {
    let task: FocusTask
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        PriorityBadge(priority: task.priority)

                        if let dueDate = task.dueDate {
                            Text(dueDate, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    FocusModeView()
        .environmentObject(FocusTimer())
        .environmentObject(TaskManager())
}
