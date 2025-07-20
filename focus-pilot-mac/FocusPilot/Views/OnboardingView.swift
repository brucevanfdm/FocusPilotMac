import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var showingAddTask = false
    
    private let steps = [
        OnboardingStep(
            icon: "target",
            title: "欢迎使用 FocusPilot",
            description: "您的智能专注助手，帮助您高效管理任务，进入深度工作状态",
            actionTitle: "开始使用"
        ),
        OnboardingStep(
            icon: "plus.circle.fill",
            title: "快速添加任务",
            description: "用自然语言描述您的任务，AI 会自动分析优先级",
            actionTitle: "添加第一个任务"
        ),
        OnboardingStep(
            icon: "brain.head.profile",
            title: "智能每日推荐",
            description: "每天早上，AI 会为您推荐最重要的任务，告别选择困难",
            actionTitle: "了解更多"
        ),
        OnboardingStep(
            icon: "timer",
            title: "一键专注模式",
            description: "选择任务后立即开始专注，极简界面帮您屏蔽干扰",
            actionTitle: "完成引导"
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 进度指示器
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .padding(.top, 20)
            
            Spacer()
            
            // 当前步骤内容
            VStack(spacing: 32) {
                // 图标
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                
                // 标题和描述
                VStack(spacing: 16) {
                    Text(steps[currentStep].title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(steps[currentStep].description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
            .frame(maxWidth: 400)
            
            Spacer()
            
            // 操作按钮
            VStack(spacing: 16) {
                Button(steps[currentStep].actionTitle) {
                    handleStepAction()
                }
                .buttonStyle(DefaultButtonStyle())
                .frame(maxWidth: 200)
                
                if currentStep > 0 {
                    Button("跳过引导") {
                        completeOnboarding()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 40)
        }
        .frame(width: 600, height: 500)
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
                .onDisappear {
                    // 添加任务后继续下一步
                    if currentStep == 1 {
                        nextStep()
                    }
                }
        }
    }
    
    private func handleStepAction() {
        switch currentStep {
        case 0:
            nextStep()
        case 1:
            showingAddTask = true
        case 2:
            nextStep()
        case 3:
            completeOnboarding()
        default:
            break
        }
    }
    
    private func nextStep() {
        if currentStep < steps.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        dismiss()
    }
}

struct OnboardingStep {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String
}

#Preview {
    OnboardingView()
}
