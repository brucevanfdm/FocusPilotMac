import SwiftUI

struct AllTasksView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var selectedFilter = TaskFilter.all
    @State private var searchText = ""
    @State private var showingAddTask = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题和控制栏
            HStack {
                Text("所有任务")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                // 数据洞察入口
                Button(action: {
                    showComingSoonAlert(feature: "生产力洞察报告")
                }) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
                .buttonStyle(.plain)
                .help("查看您的生产力数据洞察")

                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))

                    TextField("搜索任务标题、描述...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.body)

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
                .frame(width: 240)

                Button("添加任务") {
                    showingAddTask = true
                }
                .buttonStyle(DefaultButtonStyle())
            }
            .padding()
            
            // 过滤器
            HStack {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    Button(filter.displayName) {
                        selectedFilter = filter
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(selectedFilter == filter ? .white : .primary)
                    .background(selectedFilter == filter ? Color.blue : Color.clear)
                    .cornerRadius(6)
                }
                
                Spacer()
                
                Text("\(filteredTasks.count) 个任务")
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.top)
            
            // 任务列表
            if filteredTasks.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text(emptyStateMessage)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    if selectedFilter == .all && taskManager.tasks.isEmpty {
                        Button("添加第一个任务") {
                            showingAddTask = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredTasks) { task in
                            TaskRowView(task: task)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
    }
    
    private var filteredTasks: [FocusTask] {
        var tasks = taskManager.tasks
        
        // 应用过滤器
        switch selectedFilter {
        case .all:
            break
        case .pending:
            tasks = tasks.filter { $0.status == .pending }
        case .inProgress:
            tasks = tasks.filter { $0.status == .inProgress }
        case .completed:
            tasks = tasks.filter { $0.status == .completed }
        case .overdue:
            tasks = tasks.filter { $0.isOverdue }
        case .today:
            tasks = tasks.filter { $0.isRecommendedToday }
        }
        
        // 应用搜索
        if !searchText.isEmpty {
            tasks = tasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                (task.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // 排序：未完成的在前，按优先级和创建时间排序
        return tasks.sorted { task1, task2 in
            if task1.status != task2.status {
                if task1.status == .completed { return false }
                if task2.status == .completed { return true }
            }
            
            if task1.priority != task2.priority {
                return task1.priority.rawValue < task2.priority.rawValue
            }
            
            return task1.createdAt > task2.createdAt
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all:
            return "还没有任务"
        case .pending:
            return "没有待办任务"
        case .inProgress:
            return "没有进行中的任务"
        case .completed:
            return "还没有完成的任务"
        case .overdue:
            return "没有过期任务"
        case .today:
            return "今天没有推荐任务"
        }
    }

    private func showComingSoonAlert(feature: String) {
        let alert = NSAlert()
        alert.messageText = "\(feature) - 即将推出"
        alert.informativeText = "这个功能将为您提供深入的工作模式分析和个性化建议。"
        alert.addButton(withTitle: "了解")
        alert.runModal()
    }
}

struct TaskRowView: View {
    let task: FocusTask
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var focusTimer: FocusTimer
    @State private var showingTaskDetail = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 完成状态按钮
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
                    .font(.title2)
                    .foregroundColor(task.status == .completed ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            .help(task.status == .completed ? "标记为未完成" : "标记为已完成")

            // 任务信息
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.status == .completed)
                        .foregroundColor(task.status == .completed ? .secondary : .primary)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)

                    HStack(spacing: 6) {
                        if task.isRecommendedToday {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }

                        PriorityBadge(priority: task.priority)
                    }
                }

                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                // 任务元信息
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        if let dueDate = task.dueDate {
                            Label(dueDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(task.isOverdue ? .red : .secondary)
                        }

                        if !task.subtasks.isEmpty {
                            Label("\(task.subtasks.filter { $0.isCompleted }.count)/\(task.subtasks.count)", systemImage: "list.bullet")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if let estimatedDuration = task.estimatedDuration {
                            Label("\(estimatedDuration)分钟", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    Text(task.status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor.opacity(0.15))
                        .foregroundColor(statusColor)
                        .cornerRadius(6)
                }
            }
            
            // 操作按钮
            HStack(spacing: 12) {
                if task.status != .completed {
                    Button(action: {
                        let duration = focusTimer.suggestedDuration(for: task)
                        focusTimer.startTimer(for: task, duration: duration)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.circle")
                            Text("专注")
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    .help("开始专注此任务")
                }

                // 统一的操作菜单
                Menu {
                    Button(action: {
                        showingTaskDetail = true
                    }) {
                        Label("查看详情", systemImage: "info.circle")
                    }

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
    
    private var statusColor: Color {
        switch task.status {
        case .pending: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        }
    }
}

enum TaskFilter: CaseIterable {
    case all, pending, inProgress, completed, overdue, today
    
    var displayName: String {
        switch self {
        case .all: return "全部"
        case .pending: return "待办"
        case .inProgress: return "进行中"
        case .completed: return "已完成"
        case .overdue: return "过期"
        case .today: return "今日推荐"
        }
    }
}

#Preview {
    AllTasksView()
        .environmentObject(TaskManager())
        .environmentObject(FocusTimer())
}
