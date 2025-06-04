#!/bin/bash

# IQuickCal项目构建验证脚本
# 用于检查项目是否可以成功编译

echo "🚀 开始验证IQuickCal项目..."

# 检查Xcode是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 错误：未找到xcodebuild，请确保已安装Xcode"
    exit 1
fi

# 检查项目文件是否存在
PROJECT_PATH="IQuickCal.xcodeproj"
if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ 错误：未找到$PROJECT_PATH，请确保在正确的目录中运行此脚本"
    exit 1
fi

echo "✅ 找到项目文件：$PROJECT_PATH"

# 检查必要的Swift文件是否存在
echo "📋 检查必要的源文件..."

REQUIRED_FILES=(
    "IQuickCal/IQuickCalApp.swift"
    "IQuickCal/ContentView.swift"
    "IQuickCal/Models/Question.swift"
    "IQuickCal/Models/QuestionType.swift"
    "IQuickCal/Models/Answer.swift"
    "IQuickCal/Models/WrongAnswer.swift"
    "IQuickCal/Models/PracticeSession.swift"
    "IQuickCal/Models/UserPreferences.swift"
    "IQuickCal/Views/MainTabView.swift"
    "IQuickCal/Views/HomeView.swift"
    "IQuickCal/Views/PracticeView.swift"
    "IQuickCal/Views/ResultView.swift"
    "IQuickCal/Views/HistoryView.swift"
    "IQuickCal/Views/SettingsView.swift"
    "IQuickCal/Views/MistakesView.swift"
    "IQuickCal/Services/QuestionGenerator.swift"
    "IQuickCal/Services/PracticeManager.swift"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ 缺少：$file"
        exit 1
    fi
done

echo "📱 开始编译项目..."

# 尝试编译项目（仅编译，不运行）
xcodebuild -project "$PROJECT_PATH" -scheme "IQuickCal" -destination "platform=iOS Simulator,name=iPhone 15" clean build

# 检查编译结果
if [ $? -eq 0 ]; then
    echo "🎉 项目编译成功！"
    echo ""
    echo "📋 下一步操作："
    echo "1. 在Xcode中打开项目：open $PROJECT_PATH"
    echo "2. 选择目标设备或模拟器"
    echo "3. 点击Run按钮运行应用"
    echo ""
    echo "📖 更多信息请查看："
    echo "- README.md - 应用功能说明"
    echo "- TECHNICAL.md - 技术实现文档"
else
    echo "❌ 项目编译失败"
    echo "请检查以下内容："
    echo "1. 确保所有文件都已添加到Xcode项目中"
    echo "2. 检查是否有语法错误"
    echo "3. 确保iOS部署目标设置为17.0或更高"
    exit 1
fi
