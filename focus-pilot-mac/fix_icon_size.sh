#!/bin/bash

# 一键修复 macOS 应用图标大小问题

echo "🔧 FocusPilot 图标大小修复工具"
echo "=================================="
echo ""

# 检查源文件
if [ ! -f "new_icon_1024.png" ]; then
    echo "❌ 未找到 new_icon_1024.png 文件"
    echo ""
    echo "📋 请按以下步骤操作："
    echo "   1. 将你的蓝色渐变图标保存为 new_icon_1024.png"
    echo "   2. 确保尺寸为 1024x1024 像素"
    echo "   3. 放在项目根目录"
    echo "   4. 重新运行此脚本"
    exit 1
fi

echo "✅ 找到源图标文件"
echo "🎯 开始修复图标大小问题..."
echo ""

# 目标目录
ICON_DIR="FocusPilot/Assets.xcassets/AppIcon.appiconset"

# 自动选择最佳优化参数 (120% 放大)
echo "🔧 应用更大的优化参数 (120% 放大)..."
TEMP_ICON="temp_optimized_final.png"

# 放大图标以减少边距 - 使用更大的放大倍数
sips -z 1229 1229 new_icon_1024.png --out temp_large.png
sips -c 1024 1024 temp_large.png --out "$TEMP_ICON"
rm temp_large.png

echo "✅ 图标优化完成"
echo ""

# 生成所有尺寸
echo "📐 生成所有尺寸的图标..."

sips -z 16 16 "$TEMP_ICON" --out "$ICON_DIR/icon_16x16.png"
sips -z 32 32 "$TEMP_ICON" --out "$ICON_DIR/icon_16x16@2x.png"
sips -z 32 32 "$TEMP_ICON" --out "$ICON_DIR/icon_32x32.png"
sips -z 64 64 "$TEMP_ICON" --out "$ICON_DIR/icon_32x32@2x.png"
sips -z 128 128 "$TEMP_ICON" --out "$ICON_DIR/icon_128x128.png"
sips -z 256 256 "$TEMP_ICON" --out "$ICON_DIR/icon_128x128@2x.png"
sips -z 256 256 "$TEMP_ICON" --out "$ICON_DIR/icon_256x256.png"
sips -z 512 512 "$TEMP_ICON" --out "$ICON_DIR/icon_256x256@2x.png"
sips -z 512 512 "$TEMP_ICON" --out "$ICON_DIR/icon_512x512.png"
cp "$TEMP_ICON" "$ICON_DIR/icon_512x512@2x.png"

echo "✅ 所有尺寸图标生成完成"
echo ""

# 清理临时文件
rm "$TEMP_ICON"

# 清理和重建
echo "🧹 清理构建缓存..."
xcodebuild clean -project FocusPilot.xcodeproj -scheme FocusPilot > /dev/null 2>&1

echo "🗑️ 清理 Derived Data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/FocusPilot-*

echo "🔨 重新构建项目..."
xcodebuild -project FocusPilot.xcodeproj -scheme FocusPilot -configuration Debug build > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ 项目构建成功"
else
    echo "⚠️ 项目构建可能有问题，请检查 Xcode"
fi

echo ""
echo "🔄 刷新系统缓存..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user > /dev/null 2>&1

echo "🖥️ 重启 Dock..."
killall Dock

echo ""
echo "🎉 图标大小修复完成！"
echo ""
echo "📱 现在你的应用图标应该："
echo "   • 在 Dock 中显示正常大小"
echo "   • 与其他 macOS 应用图标大小一致"
echo "   • 充分利用图标画布空间"
echo ""
echo "🚀 运行应用查看效果："
echo "   open ~/Library/Developer/Xcode/DerivedData/FocusPilot-*/Build/Products/Debug/FocusPilot.app"
