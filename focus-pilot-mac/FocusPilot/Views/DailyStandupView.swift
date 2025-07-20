import SwiftUI

struct DailyStandupView: View {
    @EnvironmentObject var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTasks: Set<UUID> = []
    @State private var isGeneratingRecommendations = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Button("跳过") {
                    dismiss()
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                Text("每日智能站会")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                Button("完成") {
                    saveDailyStandup()
                    dismiss()
                }
                .buttonStyle(DefaultButtonStyle())
                .disabled(selectedTasks.isEmpty)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            if isGeneratingRecommendations {
                // 加载状态
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("AI 正在分析您的任务...")
                        .font(.headline)
                    
                    Text("根据优先级、截止日期和复杂度生成智能推荐")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else if taskManager.todayRecommendations.isEmpty {
                // 生成推荐
                VStack(spacing: 24) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 8) {
                        Text("开始您的高效一天")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("让 AI 为您分析任务优先级，推荐今日最重要的工作")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button("生成智能推荐") {
                        generateRecommendations()
                    }
                    .buttonStyle(DefaultButtonStyle())
                    .disabled(taskManager.pendingTasks.isEmpty)
                    
                    if taskManager.pendingTasks.isEmpty {
                        Text("您还没有待办任务，先去添加一些任务吧！")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                // 显示推荐结果
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI 推荐今日重点任务")
                            .font(.headline)
                        
                        Text("请选择您今天要专注的任务（建议选择 3-5 个）")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(taskManager.todayRecommendations, id: \.id) { recommendation in
                                if let task = taskManager.tasks.first(where: { $0.id == recommendation.taskId }) {
                                    RecommendationCard(
                                        task: task,
                                        recommendation: recommendation,
                                        isSelected: selectedTasks.contains(task.id)
                                    ) {
                                        toggleTaskSelection(task.id)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 重新生成按钮
                    HStack {
                        Button("重新生成推荐") {
                            generateRecommendations()
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Text("已选择 \(selectedTasks.count) 个任务")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .frame(width: 600, height: 500)
        .onAppear {
            // 如果今天还没有推荐，自动生成
            if taskManager.todayRecommendations.isEmpty && !taskManager.pendingTasks.isEmpty {
                generateRecommendations()
            } else {
                // 预选所有推荐的任务
                selectedTasks = Set(taskManager.todayRecommendations.map { $0.taskId })
            }
        }
    }
    
    private func generateRecommendations() {
        isGeneratingRecommendations = true
        
        Task {
            await taskManager.generateDailyRecommendations()
            
            await MainActor.run {
                isGeneratingRecommendations = false
                // 自动选择所有推荐的任务
                selectedTasks = Set(taskManager.todayRecommendations.map { $0.taskId })
            }
        }
    }
    
    private func toggleTaskSelection(_ taskId: UUID) {
        if selectedTasks.contains(taskId) {
            selectedTasks.remove(taskId)
        } else {
            selectedTasks.insert(taskId)
        }
    }
    
    private func saveDailyStandup() {
        // 更新任务的今日推荐状态
        for task in taskManager.tasks {
            if var updatedTask = taskManager.tasks.first(where: { $0.id == task.id }) {
                updatedTask.isRecommendedToday = selectedTasks.contains(task.id)
                taskManager.updateTask(updatedTask)
            }
        }
        
        // 记录今日站会完成时间
        UserDefaults.standard.set(Date(), forKey: "lastDailyStandup")
    }
}

struct RecommendationCard: View {
    let task: FocusTask
    let recommendation: DailyRecommendation
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var cardContent: some View {
        HStack(spacing: 16) {
            selectionIndicator
            taskDetails
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color(NSColor.controlBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .cornerRadius(12)
    }

    private var selectionIndicator: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.title2)
            .foregroundColor(isSelected ? .blue : .gray)
    }

    private var taskDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            taskHeader
            reasonText
            taskMetadata
        }
    }

    private var taskHeader: some View {
        HStack {
            Text(task.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)

            Spacer()

            PriorityBadge(priority: task.priority)
        }
    }

    private var reasonText: some View {
        Text(recommendation.reason)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .lineLimit(2)
    }

    private var taskMetadata: some View {
        HStack {
            Label("\(recommendation.suggestedDuration) 分钟", systemImage: "clock")
                .font(.caption)
                .foregroundColor(.secondary)

            if let dueDate = task.dueDate {
                Label(dueDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !task.subtasks.isEmpty {
                Text("\(task.subtasks.filter { $0.isCompleted }.count)/\(task.subtasks.count) 子任务")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    DailyStandupView()
        .environmentObject(TaskManager())
}
