# IQuickCal - iOS数学计算练习应用

## 应用概述

IQuickCal是一个专为iOS设计的数学计算练习应用，采用SwiftUI构建，旨在帮助用户提高数学计算能力。

## 主要功能

### 1. 练习模式
- **四种运算类型**：加法、减法、乘法、除法
- **自定义练习设置**：题目数量、难度级别、运算类型选择
- **实时计时**：记录练习时间，提升计算速度
- **即时反馈**：答题后立即显示正确与否

### 2. 错题管理
- **错题记录**：自动记录错误答案和用户输入
- **错误统计**：统计每道错题的错误次数
- **复习功能**：可以专门练习历史错题
- **掌握标记**：标记已掌握的错题

### 3. 进度跟踪
- **练习历史**：完整的练习会话记录
- **成绩统计**：正确率、平均用时等统计信息
- **进步曲线**：可视化展示学习进度

### 4. 个性化设置
- **用户偏好**：保存用户的练习偏好设置
- **难度调节**：根据用户水平调整题目难度
- **目标设定**：设置日常练习目标

## 技术特点

### 架构设计
- **SwiftUI**：现代化的用户界面框架
- **SwiftData**：本地数据持久化
- **MVVM模式**：清晰的代码架构

### 核心组件
- **数据模型**：Question、Answer、PracticeSession、WrongAnswer、UserPreferences
- **服务层**：QuestionGenerator（题目生成）、PracticeManager（练习管理）
- **视图层**：HomeView、PracticeView、ResultView、HistoryView、SettingsView、MistakesView

## 目录结构

```
IQuickCal/
├── IQuickCalApp.swift          # 应用入口点
├── ContentView.swift           # 根视图
├── Models/                     # 数据模型
│   ├── Question.swift
│   ├── QuestionType.swift
│   ├── Answer.swift
│   ├── WrongAnswer.swift
│   ├── PracticeSession.swift
│   └── UserPreferences.swift
├── Views/                      # 用户界面
│   ├── MainTabView.swift       # 主标签页视图
│   ├── HomeView.swift          # 首页
│   ├── PracticeView.swift      # 练习页面
│   ├── ResultView.swift        # 结果页面
│   ├── HistoryView.swift       # 历史记录
│   ├── SettingsView.swift      # 设置页面
│   └── MistakesView.swift      # 错题本
└── Services/                   # 业务逻辑
    ├── QuestionGenerator.swift # 题目生成器
    └── PracticeManager.swift   # 练习管理器
```

## 使用说明

### 开始练习
1. 在首页选择练习类型和设置
2. 点击"开始练习"进入练习模式
3. 输入答案并点击"下一题"
4. 完成所有题目后查看结果

### 查看历史
- 在"历史"标签页查看所有练习记录
- 点击具体记录查看详细信息

### 错题复习
- 在"错题本"标签页查看所有错题
- 选择特定错题进行针对性练习

### 个性化设置
- 在"设置"标签页调整练习偏好
- 设置默认题目数量、难度等级等

## 数据持久化

应用使用SwiftData进行本地数据存储，包括：
- 练习会话记录
- 错题记录
- 用户偏好设置
- 历史统计数据

## 系统要求

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 编译和运行

1. 确保所有文件都已添加到Xcode项目中
2. 在Xcode中选择目标设备或模拟器
3. 点击"Run"按钮编译并运行应用

## 后续扩展

可以考虑添加的功能：
- 更多运算类型（分数、小数、开方等）
- 竞赛模式
- 多用户支持
- 云端数据同步
- 成就系统
- 学习报告导出
