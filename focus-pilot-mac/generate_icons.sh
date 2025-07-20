#!/bin/bash

# 检查是否提供了源图标文件
if [ ! -f "new_icon_1024.png" ]; then
    echo "❌ 请先将 1024x1024 的图标文件保存为 new_icon_1024.png"
    exit 1
fi

echo "🎨 开始生成优化的应用图标..."

# 目标目录
ICON_DIR="FocusPilot/Assets.xcassets/AppIcon.appiconset"

# 创建临时优化图标（放大到充满画布）
echo "🔧 优化图标尺寸以充满画布..."
TEMP_ICON="temp_optimized_icon.png"

# 使用 sips 放大图标内容，减少边距（放大到原来的 108%，这样可以减少边距）
sips -z 1104 1104 new_icon_1024.png --out temp_large.png
# 然后裁剪回 1024x1024，这样可以去掉一些边距
sips -c 1024 1024 temp_large.png --out "$TEMP_ICON"
rm temp_large.png

# 生成各种尺寸的图标
echo "📐 生成 16x16 图标..."
sips -z 16 16 "$TEMP_ICON" --out "$ICON_DIR/icon_16x16.png"

echo "📐 生成 32x32 图标 (16x16@2x)..."
sips -z 32 32 "$TEMP_ICON" --out "$ICON_DIR/icon_16x16@2x.png"

echo "📐 生成 32x32 图标..."
sips -z 32 32 "$TEMP_ICON" --out "$ICON_DIR/icon_32x32.png"

echo "📐 生成 64x64 图标 (32x32@2x)..."
sips -z 64 64 "$TEMP_ICON" --out "$ICON_DIR/icon_32x32@2x.png"

echo "📐 生成 128x128 图标..."
sips -z 128 128 "$TEMP_ICON" --out "$ICON_DIR/icon_128x128.png"

echo "📐 生成 256x256 图标 (128x128@2x)..."
sips -z 256 256 "$TEMP_ICON" --out "$ICON_DIR/icon_128x128@2x.png"

echo "📐 生成 256x256 图标..."
sips -z 256 256 "$TEMP_ICON" --out "$ICON_DIR/icon_256x256.png"

echo "📐 生成 512x512 图标 (256x256@2x)..."
sips -z 512 512 "$TEMP_ICON" --out "$ICON_DIR/icon_256x256@2x.png"

echo "📐 生成 512x512 图标..."
sips -z 512 512 "$TEMP_ICON" --out "$ICON_DIR/icon_512x512.png"

echo "📐 生成 1024x1024 图标 (512x512@2x)..."
cp "$TEMP_ICON" "$ICON_DIR/icon_512x512@2x.png"

# 清理临时文件
rm "$TEMP_ICON"

echo "✅ 所有图标生成完成！"
echo ""
echo "🔄 现在需要："
echo "1. 清理构建缓存"
echo "2. 重新构建项目"
echo "3. 重启 Dock"
echo ""
echo "运行以下命令完成更新："
echo "chmod +x update_app_icon.sh && ./update_app_icon.sh"
