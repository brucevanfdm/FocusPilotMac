import SwiftUI

struct CommunityView: View {
    @State private var showingComingSoon = false
    
    var body: some View {
        VStack(spacing: 32) {
            // 标题
            VStack(spacing: 16) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
                
                Text("FocusPilot 社区")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("连接志同道合的专注伙伴，分享经验与成长")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // 功能预览卡片
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 24) {
                CommunityFeatureCard(
                    icon: "brain.head.profile",
                    title: "智囊团",
                    description: "与经验丰富的专业人士交流，获取个性化建议",
                    color: .purple
                )
                
                CommunityFeatureCard(
                    icon: "person.2.badge.plus",
                    title: "问责伙伴",
                    description: "找到可靠的伙伴，互相监督和激励",
                    color: .green
                )
                
                CommunityFeatureCard(
                    icon: "square.and.arrow.up",
                    title: "成果分享",
                    description: "分享您的专注成果到 X 平台，激励更多人",
                    color: .orange
                )
                
                CommunityFeatureCard(
                    icon: "chart.bar.xaxis",
                    title: "排行榜",
                    description: "查看社区专注排行，与他人良性竞争",
                    color: .red
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // 即将推出提示
            VStack(spacing: 16) {
                Text("🚀 即将推出")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text("我们正在精心打造这些社区功能，让您的专注之旅更加精彩。")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("了解更多") {
                    showComingSoonAlert()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func showComingSoonAlert() {
        let alert = NSAlert()
        alert.messageText = "社区功能 - 即将推出"
        alert.informativeText = "FocusPilot 社区将为您提供：\n\n• 与专业人士交流的智囊团\n• 互相监督的问责伙伴系统\n• 成果分享和社交功能\n• 专注排行榜和成就系统\n\n敬请期待！"
        alert.addButton(withTitle: "期待")
        alert.addButton(withTitle: "关注更新")
        
        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            if let url = URL(string: "https://focuspilot.app/community") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}

struct CommunityFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    CommunityView()
}
