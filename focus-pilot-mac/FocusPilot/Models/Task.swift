import Foundation

// 任务优先级枚举
enum TaskPriority: String, CaseIterable, Codable {
    case high = "高"
    case medium = "中"
    case low = "低"
    
    var color: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "green"
        }
    }
}

// 任务状态枚举
enum TaskStatus: String, CaseIterable, Codable {
    case pending = "待办"
    case inProgress = "进行中"
    case completed = "已完成"
}

// 主任务模型
struct FocusTask: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var description: String?
    var priority: TaskPriority
    var dueDate: Date?
    var status: TaskStatus
    var createdAt: Date
    var completedAt: Date?
    var subtasks: [SubTask]
    var estimatedDuration: Int? // 预估时长（分钟）
    var actualDuration: Int? // 实际时长（分钟）
    var isRecommendedToday: Bool // 是否为今日推荐任务
    
    init(title: String, description: String? = nil, priority: TaskPriority = .medium, dueDate: Date? = nil) {
        self.title = title
        self.description = description
        self.priority = priority
        self.dueDate = dueDate
        self.status = .pending
        self.createdAt = Date()
        self.subtasks = []
        self.isRecommendedToday = false
    }
    
    // 计算任务完成度
    var completionPercentage: Double {
        guard !subtasks.isEmpty else { return status == .completed ? 1.0 : 0.0 }
        let completedSubtasks = subtasks.filter { $0.isCompleted }.count
        return Double(completedSubtasks) / Double(subtasks.count)
    }
    
    // 是否过期
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && status != .completed
    }
    
    // 距离截止日期的天数
    var daysUntilDue: Int? {
        guard let dueDate = dueDate else { return nil }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: dueDate).day
        return days
    }
}

// 子任务模型
struct SubTask: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    
    init(title: String) {
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
    }
    
    mutating func toggle() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
}

// 每日推荐任务模型
struct DailyRecommendation: Identifiable, Codable {
    let id = UUID()
    let taskId: UUID
    let reason: String // 推荐理由
    let suggestedDuration: Int // 建议时长（分钟）
    let createdAt: Date
    
    init(taskId: UUID, reason: String, suggestedDuration: Int = 25) {
        self.taskId = taskId
        self.reason = reason
        self.suggestedDuration = suggestedDuration
        self.createdAt = Date()
    }
}

// 专注会话模型
struct FocusSession: Identifiable, Codable {
    let id = UUID()
    let taskId: UUID
    let duration: Int // 设定时长（分钟）
    var actualDuration: Int? // 实际时长（分钟）
    let startTime: Date
    var endTime: Date?
    var isCompleted: Bool

    init(taskId: UUID, duration: Int) {
        self.taskId = taskId
        self.duration = duration
        self.actualDuration = nil
        self.startTime = Date()
        self.endTime = nil
        self.isCompleted = false
    }

    // 完成会话的方法
    mutating func complete(actualDuration: Int) {
        self.actualDuration = actualDuration
        self.endTime = Date()
        self.isCompleted = true
    }
}
