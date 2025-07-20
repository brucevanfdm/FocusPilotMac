import Foundation

// 测试数据和辅助函数
extension TaskManager {
    
    // 创建示例任务用于测试
    func createSampleTasks() {
        // 清除现有任务
        tasks.removeAll()
        
        // 创建不同类型的示例任务
        let sampleTasks = [
            FocusTask(
                title: "完成用户认证模块开发",
                description: "实现用户注册、登录、密码重置功能，包括前端界面和后端API",
                priority: .high,
                dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())
            ),
            FocusTask(
                title: "撰写项目技术文档",
                description: "编写API文档、部署指南和用户手册",
                priority: .medium,
                dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())
            ),
            FocusTask(
                title: "代码审查和重构",
                description: "审查现有代码，优化性能，重构冗余部分",
                priority: .medium,
                dueDate: nil
            ),
            FocusTask(
                title: "准备客户演示",
                description: "准备产品演示PPT，安排演示环境",
                priority: .high,
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
            ),
            FocusTask(
                title: "学习新技术框架",
                description: "研究SwiftUI的高级特性，学习Combine框架",
                priority: .low,
                dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())
            ),
            FocusTask(
                title: "修复已知Bug",
                description: "修复用户反馈的界面显示问题和数据同步问题",
                priority: .high,
                dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) // 过期任务
            )
        ]
        
        // 添加任务并设置一些为已完成状态
        for (index, task) in sampleTasks.enumerated() {
            var newTask = task
            newTask.estimatedDuration = [25, 45, 60, 30, 90, 30][index]
            
            if index == 2 { // 将第三个任务设为已完成
                newTask.status = .completed
                newTask.completedAt = Calendar.current.date(byAdding: .hour, value: -2, to: Date())
            } else if index == 4 { // 将第五个任务设为进行中
                newTask.status = .inProgress
            }
            
            tasks.append(newTask)
        }
        
        // 为一些任务添加子任务
        if tasks.count > 0 {
            tasks[0].subtasks = [
                SubTask(title: "设计用户注册界面"),
                SubTask(title: "实现注册API接口"),
                SubTask(title: "添加表单验证逻辑"),
                SubTask(title: "编写单元测试")
            ]
            
            // 标记一些子任务为已完成
            tasks[0].subtasks[0].isCompleted = true
            tasks[0].subtasks[0].completedAt = Date()
        }
        
        if tasks.count > 1 {
            tasks[1].subtasks = [
                SubTask(title: "整理API接口清单"),
                SubTask(title: "编写接口文档"),
                SubTask(title: "创建部署指南"),
                SubTask(title: "编写用户手册")
            ]
        }
        
        saveTasks()
    }
    
    // 测试每日推荐功能
    func testDailyRecommendations() async {
        print("🧪 测试每日推荐功能...")
        
        // 确保有测试数据
        if tasks.isEmpty {
            createSampleTasks()
        }
        
        // 生成推荐
        await generateDailyRecommendations()
        
        // 验证结果
        print("✅ 生成了 \(todayRecommendations.count) 个推荐任务")
        for recommendation in todayRecommendations {
            if let task = tasks.first(where: { $0.id == recommendation.taskId }) {
                print("   - \(task.title): \(recommendation.reason)")
            }
        }
    }
    
    // 测试任务分解功能
    func testTaskBreakdown() async {
        print("🧪 测试任务分解功能...")
        
        // 找一个没有子任务的任务进行分解
        if let taskToBreakdown = tasks.first(where: { $0.subtasks.isEmpty && $0.status != .completed }) {
            print("   分解任务: \(taskToBreakdown.title)")
            await breakdownTask(taskToBreakdown)
            
            // 验证结果
            if let updatedTask = tasks.first(where: { $0.id == taskToBreakdown.id }) {
                print("✅ 生成了 \(updatedTask.subtasks.count) 个子任务:")
                for subtask in updatedTask.subtasks {
                    print("   - \(subtask.title)")
                }
            }
        } else {
            print("⚠️ 没有找到适合分解的任务")
        }
    }
    
    // 测试专注会话功能
    func testFocusSession() {
        print("🧪 测试专注会话功能...")
        
        if let firstTask = tasks.first {
            startFocusSession(for: firstTask, duration: 25)
            print("✅ 为任务 '\(firstTask.title)' 启动了25分钟的专注会话")
            print("   会话总数: \(focusSessions.count)")
        }
    }
    
    // 运行所有测试
    func runAllTests() async {
        print("🚀 开始运行FocusPilot核心功能测试...")
        print(String(repeating: "=", count: 50))
        
        // 创建测试数据
        createSampleTasks()
        print("✅ 创建了 \(tasks.count) 个测试任务")
        
        // 测试任务管理基本功能
        print("\n📋 测试任务管理功能...")
        print("   - 待办任务: \(pendingTasks.count)")
        print("   - 进行中任务: \(inProgressTasks.count)")
        print("   - 已完成任务: \(completedTasks.count)")
        print("   - 过期任务: \(overdueTasks.count)")
        
        // 测试每日推荐
        print("\n")
        await testDailyRecommendations()
        
        // 测试任务分解
        print("\n")
        await testTaskBreakdown()
        
        // 测试专注会话
        print("\n")
        testFocusSession()
        
        print("\n" + String(repeating: "=", count: 50))
        print("🎉 所有测试完成！")
    }
}


