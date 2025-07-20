# FocusPilot - 焦点领航

一个基于 SwiftUI 的 macOS 专注管理应用，帮助您提高工作效率和专注力。

## ✨ 主要功能

### 🎯 智能任务管理
- **任务创建与管理**：支持添加、编辑、删除任务
- **优先级设置**：高、中、低三级优先级管理
- **截止日期**：设置任务截止时间，自动识别过期任务
- **子任务分解**：支持将复杂任务分解为可执行的子任务
- **任务状态跟踪**：待办、进行中、已完成状态管理

### 🧠 AI 智能推荐
- **每日智能站会**：AI 分析任务优先级，推荐今日重要工作
- **智能任务分解**：AI 自动将复杂任务分解为具体的执行步骤
- **个性化建议**：根据任务类型和历史数据提供专注时长建议

### ⏰ 专注模式
- **番茄钟计时器**：支持自定义专注时长（15/25/45/60分钟）
- **专注会话管理**：记录每次专注会话的时长和效果
- **智能提醒**：专注完成后的声音提醒
- **会话统计**：跟踪专注时长和完成情况

### 📊 数据分析
- **任务统计**：查看任务完成情况和趋势
- **专注分析**：统计专注时长和效率
- **进度跟踪**：可视化展示工作进展

## 🚀 快速开始

### 系统要求
- macOS 14.0 或更高版本
- Xcode 15.0 或更高版本

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/your-username/focus-pilot-mac.git
   cd focus-pilot-mac
   ```

2. **打开项目**
   ```bash
   open FocusPilot.xcodeproj
   ```

3. **运行应用**
   - 在 Xcode 中选择 "My Mac" 作为运行目标
   - 点击运行按钮或使用快捷键 `Cmd + R`

## 🧪 测试功能

应用内置了完整的测试功能：

1. **自动化测试**：在调试模式下，左侧边栏底部会显示"运行测试"按钮
2. **示例数据**：自动创建示例任务用于功能演示
3. **功能验证**：测试所有核心功能的正常工作

## 🏗️ 项目结构

```
FocusPilot/
├── FocusPilotApp.swift          # 应用入口
├── ContentView.swift            # 主界面
├── Models/
│   └── Task.swift              # 任务数据模型
├── Services/
│   ├── TaskManager.swift       # 任务管理服务
│   ├── LLMService.swift        # AI 服务
│   └── FocusTimer.swift        # 专注计时器
├── Views/
│   ├── TodayFocusView.swift    # 今日专注页面
│   ├── AllTasksView.swift      # 所有任务页面
│   ├── DailyStandupView.swift  # 每日站会页面
│   ├── FocusModeView.swift     # 专注模式页面
│   ├── TaskDetailView.swift    # 任务详情页面
│   ├── AddTaskView.swift       # 添加任务页面
│   ├── OnboardingView.swift    # 用户引导页面
│   └── SettingsView.swift      # 设置页面
└── TestData.swift              # 测试数据
```

## 🎨 设计特色

- **现代化界面**：遵循 macOS 设计规范，提供原生体验
- **响应式布局**：支持窗口大小调整，最小尺寸 800x600
- **无标题栏设计**：现代化的全屏体验
- **数据持久化**：本地存储，数据安全可靠

## 🔧 技术栈

- **SwiftUI**：现代化的 UI 框架
- **Combine**：响应式编程
- **UserDefaults**：本地数据存储
- **AppKit**：macOS 系统集成

## 📝 开发说明

### 已知限制
- LLM 服务需要配置 API Key 才能正常工作
- 没有 API Key 时会使用模拟数据
- 某些高级功能可能需要网络连接

### 贡献指南
欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者和用户！

---

**FocusPilot** - 让专注成为习惯，让效率成为常态 🚀
