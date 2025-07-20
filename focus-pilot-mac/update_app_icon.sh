#!/bin/bash

echo "🧹 清理构建缓存..."
xcodebuild clean -project FocusPilot.xcodeproj -scheme FocusPilot

echo "🗑️ 删除 Derived Data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/FocusPilot-*

echo "🔨 重新构建项目..."
xcodebuild -project FocusPilot.xcodeproj -scheme FocusPilot -configuration Debug build

echo "🔄 刷新 Launch Services..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

echo "🖥️ 重启 Dock..."
killall Dock

echo "✅ 图标更新完成！"
echo ""
echo "现在可以运行应用查看新图标："
echo "open ~/Library/Developer/Xcode/DerivedData/FocusPilot-*/Build/Products/Debug/FocusPilot.app"
