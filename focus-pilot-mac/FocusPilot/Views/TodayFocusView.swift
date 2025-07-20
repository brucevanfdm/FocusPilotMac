import SwiftUI

struct TodayFocusView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var focusTimer: FocusTimer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题和刷新按钮
            HStack {
                Text("今日重点")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                // 高级智能规划入口
                Menu {
                    Button(action: {
                        showComingSoonAlert(feature: "现在-下一步-稍后 框架")
                    }) {
                        Label("现在-下一步-稍后 框架", systemImage: "list.number")
                    }

                    Button(action: {
                        showComingSoonAlert(feature: "动态优先级调整")
                    }) {
                        Label("动态优先级调整", systemImage: "arrow.up.arrow.down")
                    }

                    Button(action: {
                        showComingSoonAlert(feature: "工作模式分析")
                    }) {
                        Label("工作模式分析", systemImage: "chart.line.uptrend.xyaxis")
                    }
                } label: {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .menuStyle(.borderlessButton)
                .help("高级智能规划功能")

                Button("刷新推荐") {
                    Task {
                        await taskManager.generateDailyRecommendations()
                    }
                }
                .disabled(taskManager.isLoadingRecommendations)
            }
            
            if taskManager.isLoadingRecommendations {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("正在生成智能推荐...")
                        .foregroundColor(.secondary)
                }
            } else if taskManager.todayRecommendedTasks.isEmpty {
                EmptyTodayView(
                    hasAnyTasks: !taskManager.tasks.isEmpty,
                    onAddTask: {
                        // 触发添加任务
                        NotificationCenter.default.post(name: .showAddTask, object: nil)
                    },
                    onGenerateRecommendations: {
                        Task {
                            await taskManager.generateDailyRecommendations()
                        }
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(taskManager.todayRecommendedTasks) { task in
                            TodayTaskCard(task: task)
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func showComingSoonAlert(feature: String) {
        let alert = NSAlert()
        alert.messageText = "\(feature) - 即将推出"
        alert.informativeText = "这个高级功能正在开发中，将为您提供更智能的任务规划体验。"
        alert.addButton(withTitle: "了解")
        alert.runModal()
    }
}

struct TodayTaskCard: View {
    let task: FocusTask
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var focusTimer: FocusTimer
    @State private var showingTaskDetail = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if let reason = taskManager.todayRecommendations.first(where: { $0.taskId == task.id })?.reason {
                        Text(reason)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    PriorityBadge(priority: task.priority)
                    
                    if let dueDate = task.dueDate {
                        Text(dueDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // 进度条（如果有子任务）
            if !task.subtasks.isEmpty {
                ProgressView(value: task.completionPercentage)
                    .progressViewStyle(LinearProgressViewStyle())
                
                Text("\(Int(task.completionPercentage * 100))% 完成")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 操作按钮
            HStack(spacing: 12) {
                Button(action: {
                    let duration = focusTimer.suggestedDuration(for: task)

                    // 播放启动音效
                    NSSound(named: "Glass")?.play()

                    // 添加触觉反馈（如果支持）
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        focusTimer.startTimer(for: task, duration: duration)
                        taskManager.startFocusSession(for: task, duration: duration)

                        // 播放确认音效
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            NSSound(named: "Tink")?.play()
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("开始专注")
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)

                HStack(spacing: 8) {
                    // 问责伙伴功能预览
                    Button(action: {
                        showComingSoonAlert(feature: "问责伙伴")
                    }) {
                        Image(systemName: "person.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("邀请问责伙伴一起专注")

                    Button(action: {
                        showingTaskDetail = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                            Text("详情")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("查看任务详情")

                    Menu {
                        if task.subtasks.isEmpty && task.status != .completed {
                            Button(action: {
                                Task {
                                    await taskManager.breakdownTask(task)
                                }
                            }) {
                                Label("智能分解", systemImage: "brain")
                            }
                            .disabled(taskManager.isLoadingTaskBreakdown)
                        }

                        Divider()

                        Button("删除", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .menuStyle(.borderlessButton)
                    .help("更多操作")
                }

                Spacer()

                Button(action: {
                    if task.status == .completed {
                        var updatedTask = task
                        updatedTask.status = .pending
                        updatedTask.completedAt = nil
                        taskManager.updateTask(updatedTask)
                    } else {
                        taskManager.completeTask(task)
                    }
                }) {
                    Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(task.status == .completed ? .green : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                .help(task.status == .completed ? "标记为未完成" : "标记为已完成")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .sheet(isPresented: $showingTaskDetail) {
            TaskDetailView(task: task)
        }
        .alert("删除任务", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                taskManager.deleteTask(task)
            }
        } message: {
            Text("确定要删除任务「\(task.title)」吗？此操作无法撤销。")
        }
    }

    private func showComingSoonAlert(feature: String) {
        let alert = NSAlert()
        alert.messageText = "\(feature) - 即将推出"
        alert.informativeText = "这个功能将为您提供更丰富的协作体验。"
        alert.addButton(withTitle: "了解")
        alert.runModal()
    }
}

struct PriorityBadge: View {
    let priority: TaskPriority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(priorityColor.opacity(0.2))
            .foregroundColor(priorityColor)
            .cornerRadius(4)
    }
    
    private var priorityColor: Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

struct EmptyTodayView: View {
    let hasAnyTasks: Bool
    let onAddTask: () -> Void
    let onGenerateRecommendations: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: hasAnyTasks ? "lightbulb" : "plus.circle")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            VStack(spacing: 8) {
                Text(hasAnyTasks ? "开始您的高效一天" : "欢迎使用 FocusPilot")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(hasAnyTasks ? "让 AI 为您推荐今日最重要的任务" : "添加您的第一个任务，开始专注之旅")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if hasAnyTasks {
                Button("生成今日推荐") {
                    onGenerateRecommendations()
                }
                .buttonStyle(DefaultButtonStyle())
            } else {
                VStack(spacing: 12) {
                    Button("添加第一个任务") {
                        onAddTask()
                    }
                    .buttonStyle(DefaultButtonStyle())

                    Text("例如：\"完成项目报告\"、\"回复重要邮件\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

// MARK: - 通知扩展

extension Notification.Name {
    static let showAddTask = Notification.Name("showAddTask")
}

#Preview {
    TodayFocusView()
        .environmentObject(TaskManager())
        .environmentObject(FocusTimer())
}
