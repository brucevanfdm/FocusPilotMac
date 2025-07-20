#!/bin/bash

# 快速测试不同图标大小 - 生成预览版本

echo "🔍 快速图标大小测试工具"
echo "========================="
echo ""

# 检查源文件
if [ ! -f "new_icon_1024.png" ]; then
    echo "❌ 未找到 new_icon_1024.png 文件"
    exit 1
fi

echo "🎨 生成不同大小的预览版本..."
echo ""

# 生成多个测试版本
SIZES=(110 115 120 125 130)

for scale in "${SIZES[@]}"; do
    size=$((1024 * scale / 100))
    output="preview_${scale}percent.png"
    
    echo "📐 生成 ${scale}% 版本..."
    sips -z $size $size new_icon_1024.png --out temp_large.png > /dev/null 2>&1
    sips -c 1024 1024 temp_large.png --out "$output" > /dev/null 2>&1
    rm temp_large.png
done

echo ""
echo "✅ 预览版本生成完成！"
echo ""
echo "📁 生成的文件："
for scale in "${SIZES[@]}"; do
    echo "   • preview_${scale}percent.png - ${scale}% 大小"
done

echo ""
echo "🔍 建议："
echo "   1. 在 Finder 中查看这些预览文件"
echo "   2. 选择看起来最合适的大小"
echo "   3. 记住对应的百分比"
echo "   4. 运行 ./adjust_icon_size.sh 应用选择的大小"
echo ""
echo "💡 提示："
echo "   • 120-125% 通常效果最佳"
echo "   • 如果原图标边距很大，可以选择 130%"
echo "   • 预览文件可以安全删除"
