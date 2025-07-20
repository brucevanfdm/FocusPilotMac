#!/bin/bash

# 高级图标优化脚本 - 自动调整图标大小以匹配 macOS 标准

echo "🎯 macOS 应用图标优化工具"
echo "================================"

# 检查源文件
if [ ! -f "new_icon_1024.png" ]; then
    echo "❌ 请先将 1024x1024 的图标文件保存为 new_icon_1024.png"
    echo ""
    echo "💡 提示：确保你的图标："
    echo "   • 尺寸为 1024x1024 像素"
    echo "   • 格式为 PNG"
    echo "   • 背景透明或纯色"
    exit 1
fi

# 目标目录
ICON_DIR="FocusPilot/Assets.xcassets/AppIcon.appiconset"

echo "🔍 分析当前图标..."

# 获取图标信息
ICON_INFO=$(sips -g pixelWidth -g pixelHeight new_icon_1024.png)
echo "📊 图标信息: $ICON_INFO"

echo ""
echo "🛠️ 应用 macOS 图标优化..."
echo "   • 减少边距以充满画布"
echo "   • 优化视觉重量"
echo "   • 确保在 Dock 中显示正常大小"
echo ""

# 创建多个优化版本供选择
echo "🎨 生成优化版本..."

# 版本1: 轻微放大 (105%)
echo "   生成版本1: 轻微放大 (105%)"
sips -z 1075 1075 new_icon_1024.png --out temp_105.png
sips -c 1024 1024 temp_105.png --out optimized_105.png
rm temp_105.png

# 版本2: 中等放大 (110%)
echo "   生成版本2: 中等放大 (110%)"
sips -z 1126 1126 new_icon_1024.png --out temp_110.png
sips -c 1024 1024 temp_110.png --out optimized_110.png
rm temp_110.png

# 版本3: 较大放大 (115%)
echo "   生成版本3: 较大放大 (115%)"
sips -z 1178 1178 new_icon_1024.png --out temp_115.png
sips -c 1024 1024 temp_115.png --out optimized_115.png
rm temp_115.png

echo ""
echo "✅ 优化版本已生成！"
echo ""
echo "📋 请选择最适合的版本："
echo "   1. optimized_105.png - 轻微放大，保持原始比例"
echo "   2. optimized_110.png - 中等放大，平衡效果"
echo "   3. optimized_115.png - 较大放大，最大化填充"
echo ""
echo "🔧 使用方法："
echo "   1. 查看生成的优化版本文件"
echo "   2. 选择最满意的版本"
echo "   3. 将选中的文件重命名为 new_icon_1024.png"
echo "   4. 运行 ./generate_icons.sh 生成所有尺寸"
echo "   5. 运行 ./update_app_icon.sh 更新应用"
echo ""
echo "💡 建议："
echo "   • 大多数情况下选择版本2 (110%) 效果最佳"
echo "   • 如果图标本身边距很小，选择版本1 (105%)"
echo "   • 如果图标边距很大，选择版本3 (115%)"
