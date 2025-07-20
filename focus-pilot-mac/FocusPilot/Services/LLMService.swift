import Foundation

class LLMService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init() {
        // 在实际应用中，API Key 应该从安全的地方获取，比如 Keychain 或环境变量
        // 这里为了演示，使用一个占位符
        self.apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "your-api-key-here"
    }
    
    // MARK: - 每日推荐生成
    
    func generateDailyRecommendations(tasks: [FocusTask]) async throws -> [DailyRecommendation] {
        let prompt = buildDailyRecommendationPrompt(tasks: tasks)
        let response = try await callOpenAI(prompt: prompt, systemMessage: dailyRecommendationSystemMessage)
        return parseDailyRecommendations(response: response, tasks: tasks)
    }
    
    private let dailyRecommendationSystemMessage = """
    你是一个专业的生产力顾问，专门为一人公司和个人开发者提供每日任务优先级建议。
    
    请根据用户的任务列表，推荐3-5个今日应该优先处理的任务。考虑以下因素：
    1. 任务的优先级（高/中/低）
    2. 截止日期的紧急程度
    3. 任务的复杂度和预估时长
    4. 任务之间的依赖关系
    5. 用户的工作节奏和精力分配
    
    请以JSON格式返回推荐结果，包含：
    - taskTitle: 任务标题
    - reason: 推荐理由（一句话说明）
    - suggestedDuration: 建议专注时长（分钟）
    
    示例格式：
    [
        {
            "taskTitle": "完成用户认证模块",
            "reason": "高优先级任务，截止日期临近",
            "suggestedDuration": 45
        }
    ]
    """
    
    private func buildDailyRecommendationPrompt(tasks: [FocusTask]) -> String {
        var prompt = "以下是用户的待办任务列表：\n\n"
        
        for task in tasks {
            prompt += "任务：\(task.title)\n"
            if let description = task.description {
                prompt += "描述：\(description)\n"
            }
            prompt += "优先级：\(task.priority.rawValue)\n"
            if let dueDate = task.dueDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                prompt += "截止日期：\(formatter.string(from: dueDate))\n"
            }
            prompt += "状态：\(task.status.rawValue)\n"
            prompt += "---\n"
        }
        
        prompt += "\n请为今天推荐3-5个最重要的任务，并说明推荐理由。"
        return prompt
    }
    
    private func parseDailyRecommendations(response: String, tasks: [FocusTask]) -> [DailyRecommendation] {
        // 尝试解析 JSON 响应
        guard let data = response.data(using: .utf8) else { return [] }
        
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            var recommendations: [DailyRecommendation] = []
            
            for item in jsonArray ?? [] {
                guard let taskTitle = item["taskTitle"] as? String,
                      let reason = item["reason"] as? String,
                      let suggestedDuration = item["suggestedDuration"] as? Int else { continue }
                
                // 根据任务标题找到对应的任务ID
                if let task = tasks.first(where: { $0.title.contains(taskTitle) || taskTitle.contains($0.title) }) {
                    let recommendation = DailyRecommendation(
                        taskId: task.id,
                        reason: reason,
                        suggestedDuration: suggestedDuration
                    )
                    recommendations.append(recommendation)
                }
            }
            
            return recommendations
        } catch {
            print("解析每日推荐失败: \(error)")
            return generateFallbackRecommendations(tasks: tasks)
        }
    }
    
    // MARK: - 任务分解
    
    func breakdownTask(_ task: FocusTask) async throws -> [SubTask] {
        let prompt = buildTaskBreakdownPrompt(task: task)
        let response = try await callOpenAI(prompt: prompt, systemMessage: taskBreakdownSystemMessage)
        return parseTaskBreakdown(response: response)
    }
    
    private let taskBreakdownSystemMessage = """
    你是一个专业的项目管理顾问，擅长将复杂任务分解为可执行的具体步骤。
    
    请将用户提供的任务分解为3-8个具体的、可执行的子任务。每个子任务应该：
    1. 明确具体，避免模糊表述
    2. 可以在30分钟到2小时内完成
    3. 有清晰的完成标准
    4. 按照逻辑顺序排列
    
    请以JSON数组格式返回，每个元素包含：
    - title: 子任务标题
    
    示例格式：
    [
        {"title": "设计用户注册界面原型"},
        {"title": "实现用户注册API接口"},
        {"title": "编写用户注册表单验证逻辑"}
    ]
    """
    
    private func buildTaskBreakdownPrompt(task: FocusTask) -> String {
        var prompt = "请将以下任务分解为具体的子任务：\n\n"
        prompt += "任务标题：\(task.title)\n"
        
        if let description = task.description {
            prompt += "任务描述：\(description)\n"
        }
        
        prompt += "优先级：\(task.priority.rawValue)\n"
        
        if let dueDate = task.dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            prompt += "截止日期：\(formatter.string(from: dueDate))\n"
        }
        
        return prompt
    }
    
    private func parseTaskBreakdown(response: String) -> [SubTask] {
        guard let data = response.data(using: .utf8) else { return [] }
        
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            var subtasks: [SubTask] = []
            
            for item in jsonArray ?? [] {
                if let title = item["title"] as? String {
                    subtasks.append(SubTask(title: title))
                }
            }
            
            return subtasks
        } catch {
            print("解析任务分解失败: \(error)")
            return generateFallbackSubtasks(for: response)
        }
    }
    
    // MARK: - OpenAI API 调用
    
    private func callOpenAI(prompt: String, systemMessage: String) async throws -> String {
        guard !apiKey.isEmpty && apiKey != "your-api-key-here" else {
            // 如果没有配置 API Key，返回模拟数据
            return generateMockResponse(for: prompt, systemMessage: systemMessage)
        }
        
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": systemMessage],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 1000,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LLMServiceError.apiError("API 调用失败")
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = jsonResponse?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        let content = message?["content"] as? String
        
        return content ?? ""
    }
    
    // MARK: - 模拟响应（用于演示）
    
    private func generateMockResponse(for prompt: String, systemMessage: String) -> String {
        // 检查是否是每日推荐请求
        if systemMessage.contains("生产力顾问") || systemMessage.contains("每日任务优先级建议") || prompt.contains("推荐") {
            // 从prompt中提取任务信息，生成更真实的推荐
            let taskTitles = extractTaskTitlesFromPrompt(prompt)

            if taskTitles.isEmpty {
                // 如果没有找到任务，返回默认推荐
                return """
                [
                    {
                        "taskTitle": "完成核心功能开发",
                        "reason": "高优先级任务，对项目进展至关重要",
                        "suggestedDuration": 45
                    },
                    {
                        "taskTitle": "代码审查和优化",
                        "reason": "确保代码质量，避免后期技术债务",
                        "suggestedDuration": 30
                    },
                    {
                        "taskTitle": "文档更新",
                        "reason": "保持文档同步，便于团队协作",
                        "suggestedDuration": 25
                    }
                ]
                """
            } else {
                // 基于实际任务生成推荐
                return generateRecommendationsFromTasks(taskTitles)
            }
        } else {
            return """
            [
                {"title": "分析需求和设计方案"},
                {"title": "创建基础代码结构"},
                {"title": "实现核心功能逻辑"},
                {"title": "编写单元测试"},
                {"title": "进行功能测试和调试"}
            ]
            """
        }
    }

    private func extractTaskTitlesFromPrompt(_ prompt: String) -> [String] {
        let lines = prompt.components(separatedBy: .newlines)
        var taskTitles: [String] = []

        for line in lines {
            if line.hasPrefix("任务：") {
                let title = String(line.dropFirst(3)).trimmingCharacters(in: .whitespacesAndNewlines)
                if !title.isEmpty {
                    taskTitles.append(title)
                }
            }
        }

        return taskTitles
    }

    private func generateRecommendationsFromTasks(_ taskTitles: [String]) -> String {
        let recommendations = taskTitles.prefix(3).enumerated().map { index, title in
            let reasons = [
                "高优先级任务，建议优先处理",
                "截止日期临近，需要及时完成",
                "重要任务，对整体进展有关键影响",
                "基础任务，为后续工作奠定基础",
                "核心功能，影响项目成功"
            ]
            let durations = [25, 30, 45, 60]

            return """
                {
                    "taskTitle": "\(title)",
                    "reason": "\(reasons[index % reasons.count])",
                    "suggestedDuration": \(durations[index % durations.count])
                }
            """
        }

        return "[\n" + recommendations.joined(separator: ",\n") + "\n]"
    }
    
    // MARK: - 备用方案
    
    private func generateFallbackRecommendations(tasks: [FocusTask]) -> [DailyRecommendation] {
        let sortedTasks = tasks.sorted { task1, task2 in
            // 按优先级和截止日期排序
            if task1.priority != task2.priority {
                return task1.priority.rawValue < task2.priority.rawValue
            }
            
            if let date1 = task1.dueDate, let date2 = task2.dueDate {
                return date1 < date2
            }
            
            return task1.createdAt < task2.createdAt
        }
        
        return Array(sortedTasks.prefix(3)).map { task in
            DailyRecommendation(
                taskId: task.id,
                reason: "基于优先级和截止日期的智能推荐",
                suggestedDuration: 30
            )
        }
    }
    
    private func generateFallbackSubtasks(for taskTitle: String) -> [SubTask] {
        return [
            SubTask(title: "分析任务需求"),
            SubTask(title: "制定执行计划"),
            SubTask(title: "开始具体实施"),
            SubTask(title: "检查和完善结果")
        ]
    }
}

enum LLMServiceError: Error {
    case apiError(String)
    case parseError(String)
}
