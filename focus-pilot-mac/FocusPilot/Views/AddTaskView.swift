import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority = TaskPriority.medium
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var estimatedDuration = 30
    @State private var showingDurationPicker = false
    
    private let durations = [15, 25, 30, 45, 60, 90, 120]
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Button("取消") {
                    dismiss()
                }
                
                Spacer()
                
                Text("添加新任务")
                    .font(.headline)
                
                Spacer()
                
                Button("保存") {
                    saveTask()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // 表单内容
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 任务标题
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("任务标题")
                                .font(.headline)
                            Text("*")
                                .foregroundColor(.red)
                                .font(.headline)
                        }

                        TextField("输入任务标题，例如：完成项目报告、学习新技能等", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                            .onSubmit {
                                // 自动解析任务标题，提取可能的优先级和时长信息
                                parseTaskTitle()
                            }
                    }
                    
                    // 任务描述
                    VStack(alignment: .leading, spacing: 8) {
                        Text("任务描述")
                            .font(.headline)

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(NSColor.textBackgroundColor))
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                                .frame(minHeight: 80)

                            if description.isEmpty {
                                Text("详细描述任务内容，包括具体步骤、注意事项等...")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .allowsHitTesting(false)
                            }

                            TextEditor(text: $description)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .frame(minHeight: 80)
                        }
                    }
                    
                    // 优先级选择
                    VStack(alignment: .leading, spacing: 8) {
                        Text("优先级")
                            .font(.headline)
                        
                        Picker("优先级", selection: $priority) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                HStack {
                                    Circle()
                                        .fill(priorityColor(priority))
                                        .frame(width: 12, height: 12)
                                    Text(priority.rawValue)
                                }
                                .tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // 截止日期
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("截止日期")
                                .font(.headline)

                            Spacer()

                            Toggle("设置截止日期", isOn: $hasDueDate)
                                .toggleStyle(.switch)
                        }

                        if hasDueDate {
                            VStack(alignment: .leading, spacing: 8) {
                                DatePicker("选择截止日期", selection: $dueDate, displayedComponents: [.date])
                                    .datePickerStyle(.compact)
                                    .labelsHidden()

                                // 显示相对时间提示
                                if let days = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day {
                                    Text(relativeDateText(days: days))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.leading, 16)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    // 预估时长
                    VStack(alignment: .leading, spacing: 12) {
                        Text("预估时长")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Button(action: {
                                    showingDurationPicker.toggle()
                                }) {
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(.blue)
                                        Text("\(estimatedDuration) 分钟")
                                            .fontWeight(.medium)
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(NSColor.controlBackgroundColor))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                .popover(isPresented: $showingDurationPicker) {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("选择预估时长")
                                            .font(.headline)

                                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                            ForEach(durations, id: \.self) { duration in
                                                Button(action: {
                                                    estimatedDuration = duration
                                                    showingDurationPicker = false
                                                }) {
                                                    VStack(spacing: 4) {
                                                        Text("\(duration)")
                                                            .font(.title2)
                                                            .fontWeight(.semibold)
                                                        Text("分钟")
                                                            .font(.caption)
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 12)
                                                    .background(estimatedDuration == duration ? Color.blue : Color(NSColor.controlBackgroundColor))
                                                    .foregroundColor(estimatedDuration == duration ? .white : .primary)
                                                    .cornerRadius(8)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }

                                        Divider()

                                        HStack {
                                            TextField("自定义时长", value: $estimatedDuration, format: .number)
                                                .textFieldStyle(.roundedBorder)
                                            Text("分钟")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .frame(width: 260)
                                }

                                Spacer()
                            }

                            Text("💡 建议使用番茄工作法（25分钟专注 + 5分钟休息）")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                        }
                    }
                    
                    // 快速模板
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("快速模板")
                                .font(.headline)
                            Spacer()
                            Text("点击应用预设配置")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            QuickTemplateButton(
                                title: "编程开发",
                                icon: "laptopcomputer",
                                priority: .high,
                                duration: 45,
                                description: "高优先级 • 45分钟"
                            ) { template in
                                applyTemplate(template)
                            }

                            QuickTemplateButton(
                                title: "会议沟通",
                                icon: "person.2.fill",
                                priority: .medium,
                                duration: 30,
                                description: "中优先级 • 30分钟"
                            ) { template in
                                applyTemplate(template)
                            }

                            QuickTemplateButton(
                                title: "文档写作",
                                icon: "doc.text.fill",
                                priority: .medium,
                                duration: 60,
                                description: "中优先级 • 60分钟"
                            ) { template in
                                applyTemplate(template)
                            }

                            QuickTemplateButton(
                                title: "学习研究",
                                icon: "book.fill",
                                priority: .low,
                                duration: 25,
                                description: "低优先级 • 25分钟"
                            ) { template in
                                applyTemplate(template)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
        .frame(width: 520, height: 650)
    }
    
    private func parseTaskTitle() {
        let lowercaseTitle = title.lowercased()
        
        // 自动推断优先级
        if lowercaseTitle.contains("紧急") || lowercaseTitle.contains("重要") || lowercaseTitle.contains("urgent") {
            priority = .high
        } else if lowercaseTitle.contains("一般") || lowercaseTitle.contains("normal") {
            priority = .medium
        } else if lowercaseTitle.contains("低") || lowercaseTitle.contains("low") {
            priority = .low
        }
        
        // 自动推断时长
        if lowercaseTitle.contains("会议") || lowercaseTitle.contains("电话") {
            estimatedDuration = 30
        } else if lowercaseTitle.contains("编程") || lowercaseTitle.contains("开发") || lowercaseTitle.contains("代码") {
            estimatedDuration = 45
        } else if lowercaseTitle.contains("写作") || lowercaseTitle.contains("文档") {
            estimatedDuration = 60
        }
    }
    
    private func applyTemplate(_ template: TaskTemplate) {
        priority = template.priority
        estimatedDuration = template.duration
    }
    
    private func saveTask() {
        let finalDueDate = hasDueDate ? dueDate : nil
        
        taskManager.addTask(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: priority,
            dueDate: finalDueDate
        )
        
        // 更新任务的预估时长
        if let newTask = taskManager.tasks.last {
            var updatedTask = newTask
            updatedTask.estimatedDuration = estimatedDuration
            taskManager.updateTask(updatedTask)
        }
        
        dismiss()
    }
    
    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
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

struct QuickTemplateButton: View {
    let title: String
    let icon: String
    let priority: TaskPriority
    let duration: Int
    let description: String
    let onApply: (TaskTemplate) -> Void

    var body: some View {
        Button(action: {
            onApply(TaskTemplate(title: title, priority: priority, duration: duration))
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)

                VStack(spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)

                    Text(description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(NSColor.separatorColor).opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
}

struct TaskTemplate {
    let title: String
    let priority: TaskPriority
    let duration: Int
}

#Preview {
    AddTaskView()
        .environmentObject(TaskManager())
}
