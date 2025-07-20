import Foundation
import Combine

class TaskManager: ObservableObject {
    @Published var tasks: [FocusTask] = []
    @Published var todayRecommendations: [DailyRecommendation] = []
    @Published var focusSessions: [FocusSession] = []
    @Published var isLoadingRecommendations = false
    @Published var isLoadingTaskBreakdown = false
    
    private let llmService = LLMService()
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "FocusPilot_Tasks"
    private let recommendationsKey = "FocusPilot_Recommendations"
    private let sessionsKey = "FocusPilot_Sessions"
    
    init() {
        loadTasks()
        loadRecommendations()
        loadSessions()

        // 如果没有任务，创建示例数据（仅在调试模式下）
        #if DEBUG
        if tasks.isEmpty {
            createSampleTasks()
        }
        #endif
    }
    
    // MARK: - 任务管理
    
    func addTask(title: String, description: String? = nil, priority: TaskPriority = .medium, dueDate: Date? = nil) {
        let task = FocusTask(title: title, description: description, priority: priority, dueDate: dueDate)
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: FocusTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: FocusTask) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func completeTask(_ task: FocusTask) {
        var updatedTask = task
        updatedTask.status = .completed
        updatedTask.completedAt = Date()
        updateTask(updatedTask)
    }

    func clearCompletedTasks() {
        tasks.removeAll { $0.status == .completed }
        saveTasks()
    }
    
    func toggleSubtask(taskId: UUID, subtaskId: UUID) {
        if let taskIndex = tasks.firstIndex(where: { $0.id == taskId }),
           let subtaskIndex = tasks[taskIndex].subtasks.firstIndex(where: { $0.id == subtaskId }) {
            tasks[taskIndex].subtasks[subtaskIndex].toggle()
            
            // 检查是否所有子任务都完成了
            let allSubtasksCompleted = tasks[taskIndex].subtasks.allSatisfy { $0.isCompleted }
            if allSubtasksCompleted && !tasks[taskIndex].subtasks.isEmpty {
                tasks[taskIndex].status = .completed
                tasks[taskIndex].completedAt = Date()
            } else if tasks[taskIndex].status == .completed {
                tasks[taskIndex].status = .inProgress
                tasks[taskIndex].completedAt = nil
            }
            
            saveTasks()
        }
    }
    
    // MARK: - 每日推荐
    
    func generateDailyRecommendations() async {
        print("🔄 开始生成每日推荐...")

        await MainActor.run {
            isLoadingRecommendations = true
        }

        do {
            let pendingTasks = tasks.filter { $0.status != .completed }
            print("📋 找到 \(pendingTasks.count) 个待处理任务")

            let recommendations = try await llmService.generateDailyRecommendations(tasks: pendingTasks)
            print("✅ 生成了 \(recommendations.count) 个推荐")

            await MainActor.run {
                self.todayRecommendations = recommendations
                self.isLoadingRecommendations = false
                self.saveRecommendations()

                // 更新任务的推荐状态
                for recommendation in recommendations {
                    if let index = self.tasks.firstIndex(where: { $0.id == recommendation.taskId }) {
                        self.tasks[index].isRecommendedToday = true
                    }
                }
                self.saveTasks()

                print("💾 推荐已保存，推荐任务数: \(self.todayRecommendedTasks.count)")
            }
        } catch {
            await MainActor.run {
                self.isLoadingRecommendations = false
                print("❌ 生成每日推荐失败: \(error)")
            }
        }
    }
    
    // MARK: - 任务分解
    
    func breakdownTask(_ task: FocusTask) async {
        await MainActor.run {
            isLoadingTaskBreakdown = true
        }
        
        do {
            let subtasks = try await llmService.breakdownTask(task)
            
            await MainActor.run {
                if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                    self.tasks[index].subtasks = subtasks
                    self.saveTasks()
                }
                self.isLoadingTaskBreakdown = false
            }
        } catch {
            await MainActor.run {
                self.isLoadingTaskBreakdown = false
                print("任务分解失败: \(error)")
            }
        }
    }
    
    // MARK: - 专注会话
    
    func startFocusSession(for task: FocusTask, duration: Int) {
        let session = FocusSession(taskId: task.id, duration: duration)
        focusSessions.append(session)
        
        // 更新任务状态为进行中
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].status = .inProgress
        }
        
        saveSessions()
        saveTasks()
    }
    
    func completeFocusSession(_ session: FocusSession, actualDuration: Int) {
        if let index = focusSessions.firstIndex(where: { $0.id == session.id }) {
            focusSessions[index].complete(actualDuration: actualDuration)
        }

        saveSessions()
    }
    
    // MARK: - 数据持久化
    
    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = userDefaults.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([FocusTask].self, from: data) {
            tasks = decoded
        }
    }
    
    private func saveRecommendations() {
        if let encoded = try? JSONEncoder().encode(todayRecommendations) {
            userDefaults.set(encoded, forKey: recommendationsKey)
        }
    }
    
    private func loadRecommendations() {
        if let data = userDefaults.data(forKey: recommendationsKey),
           let decoded = try? JSONDecoder().decode([DailyRecommendation].self, from: data) {
            // 只加载今天的推荐
            let today = Calendar.current.startOfDay(for: Date())
            todayRecommendations = decoded.filter { 
                Calendar.current.isDate($0.createdAt, inSameDayAs: today)
            }
        }
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(focusSessions) {
            userDefaults.set(encoded, forKey: sessionsKey)
        }
    }
    
    private func loadSessions() {
        if let data = userDefaults.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
            focusSessions = decoded
        }
    }
    
    // MARK: - 计算属性
    
    var pendingTasks: [FocusTask] {
        tasks.filter { $0.status == .pending }
    }
    
    var inProgressTasks: [FocusTask] {
        tasks.filter { $0.status == .inProgress }
    }
    
    var completedTasks: [FocusTask] {
        tasks.filter { $0.status == .completed }
    }
    
    var todayRecommendedTasks: [FocusTask] {
        let recommendedIds = Set(todayRecommendations.map { $0.taskId })
        return tasks.filter { recommendedIds.contains($0.id) }
    }
    
    var overdueTasks: [FocusTask] {
        tasks.filter { $0.isOverdue }
    }
}
