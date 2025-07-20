import SwiftUI

struct TaskDetailView: View {
    @State var task: FocusTask
    @EnvironmentObject var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var editedDescription = ""
    @State private var editedPriority = TaskPriority.medium
    @State private var editedDueDate = Date()
    @State private var hasEditedDueDate = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Button("关闭") {
                    dismiss()
                }

                Spacer()

                Text(isEditing ? "编辑任务" : "任务详情")
                    .font(.headline)

                Spacer()

                HStack(spacing: 12) {
                    if !isEditing {
                        Menu {
                            Button("删除", role: .destructive) {
                                showingDeleteAlert = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.secondary)
                        }
                        .menuStyle(.borderlessButton)
                        .help("更多操作")
                    }

                    if isEditing {
                        Button("保存") {
                            saveChanges()
                        }
                        .buttonStyle(DefaultButtonStyle())
                        .disabled(editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    } else {
                        Button("编辑") {
                            startEditing()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 基本信息
                    VStack(alignment: .leading, spacing: 16) {
                        if isEditing {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("任务标题")
                                        .font(.headline)
                                    Text("*")
                                        .foregroundColor(.red)
                                        .font(.headline)
                                }
                                TextField("输入任务标题，例如：完成项目报告、学习新技能等", text: $editedTitle)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.body)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("任务描述")
                                    .font(.headline)

                                ZStack(alignment: .topLeading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(NSColor.textBackgroundColor))
                                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                                        .frame(minHeight: 80)

                                    if editedDescription.isEmpty {
                                        Text("详细描述任务内容，包括具体步骤、注意事项等...")
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 6)
                                            .allowsHitTesting(false)
                                    }

                                    TextEditor(text: $editedDescription)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.clear)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .frame(minHeight: 80)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("优先级")
                                    .font(.headline)
                                Picker("优先级", selection: $editedPriority) {
                                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                                        Text(priority.rawValue).tag(priority)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("截止日期")
                                        .font(.headline)
                                    Spacer()
                                    Toggle("设置截止日期", isOn: $hasEditedDueDate)
                                        .toggleStyle(.switch)
                                }

                                if hasEditedDueDate {
                                    VStack(alignment: .leading, spacing: 8) {
                                        DatePicker("选择截止日期", selection: $editedDueDate, displayedComponents: [.date])
                                            .datePickerStyle(.compact)
                                            .labelsHidden()

                                        // 显示相对时间提示
                                        if let days = Calendar.current.dateComponents([.day], from: Date(), to: editedDueDate).day {
                                            Text(relativeDateText(days: days))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.leading, 16)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(task.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                if let description = task.description, !description.isEmpty {
                                    Text(description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    PriorityBadge(priority: task.priority)
                                    
                                    Text(task.status.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(statusColor.opacity(0.2))
                                        .foregroundColor(statusColor)
                                        .cornerRadius(4)
                                    
                                    if task.isRecommendedToday {
                                        HStack {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                            Text("今日推荐")
                                        }
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.yellow.opacity(0.2))
                                        .foregroundColor(.orange)
                                        .cornerRadius(4)
                                    }
                                }
                                
                                if let dueDate = task.dueDate {
                                    HStack {
                                        Image(systemName: "calendar")
                                        Text("截止日期: \(dueDate, style: .date)")
                                        
                                        if task.isOverdue {
                                            Text("(已过期)")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(task.isOverdue ? .red : .secondary)
                                }
                                
                                HStack {
                                    Image(systemName: "clock")
                                    Text("创建时间: \(task.createdAt, style: .date)")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                
                                if let completedAt = task.completedAt {
                                    HStack {
                                        Image(systemName: "checkmark.circle")
                                        Text("完成时间: \(completedAt, style: .date)")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // 子任务部分
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("子任务")
                                .font(.headline)
                            
                            Spacer()
                            
                            if !task.subtasks.isEmpty {
                                Text("\(task.subtasks.filter { $0.isCompleted }.count)/\(task.subtasks.count) 完成")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if task.subtasks.isEmpty && !isEditing {
                                Button("智能分解") {
                                    Task {
                                        await taskManager.breakdownTask(task)
                                        // 刷新任务数据
                                        if let updatedTask = taskManager.tasks.first(where: { $0.id == task.id }) {
                                            self.task = updatedTask
                                        }
                                    }
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .disabled(taskManager.isLoadingTaskBreakdown)
                            }
                        }
                        
                        if task.subtasks.isEmpty {
                            if taskManager.isLoadingTaskBreakdown {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("正在智能分解任务...")
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Text("暂无子任务")
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        } else {
                            // 进度条
                            ProgressView(value: task.completionPercentage)
                                .progressViewStyle(LinearProgressViewStyle())
                            
                            Text("\(Int(task.completionPercentage * 100))% 完成")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // 子任务列表
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(task.subtasks) { subtask in
                                    SubtaskRow(
                                        subtask: subtask,
                                        onToggle: {
                                            taskManager.toggleSubtask(taskId: task.id, subtaskId: subtask.id)
                                            // 刷新任务数据
                                            if let updatedTask = taskManager.tasks.first(where: { $0.id == task.id }) {
                                                self.task = updatedTask
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // 统计信息
                    VStack(alignment: .leading, spacing: 12) {
                        Text("统计信息")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            if let estimatedDuration = task.estimatedDuration {
                                HStack {
                                    Text("预估时长:")
                                    Spacer()
                                    Text("\(estimatedDuration) 分钟")
                                }
                                .font(.subheadline)
                            }
                            
                            if let actualDuration = task.actualDuration {
                                HStack {
                                    Text("实际时长:")
                                    Spacer()
                                    Text("\(actualDuration) 分钟")
                                }
                                .font(.subheadline)
                            }
                            
                            if let daysUntilDue = task.daysUntilDue {
                                HStack {
                                    Text("距离截止:")
                                    Spacer()
                                    Text("\(daysUntilDue) 天")
                                        .foregroundColor(daysUntilDue < 0 ? .red : (daysUntilDue <= 3 ? .orange : .primary))
                                }
                                .font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 600)
        .onAppear {
            // 监听任务更新
            if let updatedTask = taskManager.tasks.first(where: { $0.id == task.id }) {
                self.task = updatedTask
            }
        }
        .alert("删除任务", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                taskManager.deleteTask(task)
                dismiss()
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
    
    private func startEditing() {
        editedTitle = task.title
        editedDescription = task.description ?? ""
        editedPriority = task.priority
        editedDueDate = task.dueDate ?? Date()
        hasEditedDueDate = task.dueDate != nil
        isEditing = true
    }
    
    private func saveChanges() {
        var updatedTask = task
        updatedTask.title = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedTask.description = editedDescription.isEmpty ? nil : editedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedTask.priority = editedPriority
        updatedTask.dueDate = hasEditedDueDate ? editedDueDate : nil
        
        taskManager.updateTask(updatedTask)
        task = updatedTask
        isEditing = false
    }

    private func relativeDateText(days: Int) -> String {
        switch days {
        case 0:
            return "📅 今天截止"
        case 1:
            return "📅 明天截止"
        case 2...7:
            return "📅 \(days) 天后截止"
        case let d where d > 7:
            return "📅 \(days) 天后截止"
        case -1:
            return "⚠️ 昨天已截止"
        case let d where d < -1:
            return "⚠️ 已逾期 \(abs(d)) 天"
        default:
            return "📅 \(days) 天后截止"
        }
    }
}

struct SubtaskRow: View {
    let subtask: SubTask
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(subtask.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(subtask.title)
                .strikethrough(subtask.isCompleted)
                .foregroundColor(subtask.isCompleted ? .secondary : .primary)
            
            Spacer()
            
            if let completedAt = subtask.completedAt {
                Text(completedAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TaskDetailView(task: FocusTask(title: "示例任务", description: "这是一个示例任务", priority: .high))
        .environmentObject(TaskManager())
}
