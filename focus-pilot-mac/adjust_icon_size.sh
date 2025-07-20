#!/bin/bash

# 交互式图标大小调整工具

echo "🎯 FocusPilot 图标大小精细调整工具"
echo "===================================="
echo ""

# 检查源文件
if [ ! -f "new_icon_1024.png" ]; then
    echo "❌ 未找到 new_icon_1024.png 文件"
    echo "请先将你的蓝色渐变图标保存为 new_icon_1024.png"
    exit 1
fi

echo "✅ 找到源图标文件"
echo ""
echo "📏 当前状态：图标比其他应用稍小，需要再大一些"
echo ""
echo "🎚️ 请选择放大级别："
echo "   1. 115% - 轻微增大"
echo "   2. 120% - 中等增大 (推荐)"
echo "   3. 125% - 较大增大"
echo "   4. 130% - 最大增大"
echo "   5. 自定义百分比"
echo ""

read -p "请输入选择 (1-5): " choice

case $choice in
    1)
        SCALE=115
        SIZE=1178
        echo "🔧 应用 115% 放大..."
        ;;
    2)
        SCALE=120
        SIZE=1229
        echo "🔧 应用 120% 放大 (推荐)..."
        ;;
    3)
        SCALE=125
        SIZE=1280
        echo "🔧 应用 125% 放大..."
        ;;
    4)
        SCALE=130
        SIZE=1331
        echo "🔧 应用 130% 放大..."
        ;;
    5)
        read -p "请输入自定义百分比 (100-150): " SCALE
        if [ "$SCALE" -lt 100 ] || [ "$SCALE" -gt 150 ]; then
            echo "❌ 百分比必须在 100-150 之间"
            exit 1
        fi
        SIZE=$((1024 * SCALE / 100))
        echo "🔧 应用 ${SCALE}% 放大..."
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""

# 目标目录
ICON_DIR="FocusPilot/Assets.xcassets/AppIcon.appiconset"
TEMP_ICON="temp_optimized_${SCALE}.png"

# 应用放大
echo "📐 生成 ${SCALE}% 放大的图标..."
sips -z $SIZE $SIZE new_icon_1024.png --out temp_large.png
sips -c 1024 1024 temp_large.png --out "$TEMP_ICON"
rm temp_large.png

echo "✅ 图标优化完成"
echo ""

# 生成所有尺寸
echo "🎨 生成所有尺寸的图标..."

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

# 保存优化版本供参考
cp "$TEMP_ICON" "optimized_${SCALE}percent.png"
echo "💾 已保存优化版本为: optimized_${SCALE}percent.png"

# 清理临时文件
rm "$TEMP_ICON"

echo ""
echo "🔄 更新应用..."

# 快速更新（不显示详细输出）
echo "   清理缓存..."
xcodebuild clean -project FocusPilot.xcodeproj -scheme FocusPilot > /dev/null 2>&1
rm -rf ~/Library/Developer/Xcode/DerivedData/FocusPilot-*

echo "   重新构建..."
xcodebuild -project FocusPilot.xcodeproj -scheme FocusPilot -configuration Debug build > /dev/null 2>&1

echo "   刷新系统缓存..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user > /dev/null 2>&1
killall Dock

echo ""
echo "🎉 图标已更新为 ${SCALE}% 大小！"
echo ""
echo "📱 现在请检查 Dock 中的图标大小："
echo "   • 如果还是偏小，重新运行脚本选择更大的百分比"
echo "   • 如果太大了，选择较小的百分比"
echo "   • 如果大小合适，恭喜完成！"
echo ""
echo "🚀 运行应用查看效果："
echo "   open ~/Library/Developer/Xcode/DerivedData/FocusPilot-*/Build/Products/Debug/FocusPilot.app"
