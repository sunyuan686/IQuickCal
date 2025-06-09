#!/bin/bash

# 测试手写功能的脚本
echo "🎨 测试全屏手写功能"
echo "=============================="

echo "1. 构建项目..."
cd /Users/sunyuan/develop/project/ios/IQuickCal
xcodebuild -project IQuickCal.xcodeproj -scheme IQuickCal -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ 项目构建成功"
else
    echo "❌ 项目构建失败"
    exit 1
fi

echo ""
echo "2. 启动iOS模拟器..."
open -a Simulator

# 等待模拟器启动
sleep 3

echo ""
echo "3. 安装并运行应用..."
xcodebuild -project IQuickCal.xcodeproj -scheme IQuickCal -destination 'platform=iOS Simulator,name=iPhone 15 Pro' run > /dev/null 2>&1 &

sleep 5

echo ""
echo "🎉 手写功能测试指南："
echo "----------------------------"
echo "1. 在模拟器中选择"多位数除以三位数"或"四位数除法"题型"
echo "2. 开始练习后，你会看到题目旁边有一个橙色的铅笔图标 🖊️"
echo "3. 点击铅笔图标，将会开启全屏手写模式"
echo "4. 现在可以在整个屏幕上自由绘制草稿"
echo "5. 使用顶部工具栏调整笔触粗细和颜色"
echo "6. 使用"清除"按钮清空画布"
echo "7. 点击"完成"或"关闭"按钮退出手写模式"
echo ""
echo "✨ 主要改进："
echo "   - 从小画框改为全屏画布"
echo "   - 优化了工具栏布局和样式"
echo "   - 仅在需要"动笔"的题型显示手写功能"
echo "   - 流畅的进入和退出动画"

echo ""
echo "📱 模拟器操作提示："
echo "   - 使用鼠标/触控板模拟手写操作"
echo "   - 在模拟器中测试完整的手写体验"
