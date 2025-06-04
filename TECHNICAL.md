# IQuickCal 技术文档

## 项目架构

### 1. 数据层 (Models)

#### 核心数据模型
所有模型类都使用SwiftData的`@Model`装饰器，支持自动持久化。

**Question.swift**
- 表示一道数学题目
- 包含表达式、正确答案、题目类型等属性
- 自动生成唯一ID和创建时间

**QuestionType.swift**
- 枚举类型，定义四种运算：加法、减法、乘法、除法
- 符合CaseIterable协议，便于界面选择

**Answer.swift**
- 记录用户的答题信息
- 包含用户答案、是否正确、答题时间等

**WrongAnswer.swift**
- 专门记录错题信息
- 支持错误次数统计和掌握状态标记
- 提供addWrongAttempt()和markAsMastered()方法

**PracticeSession.swift**
- 记录完整的练习会话
- 包含会话统计信息：总题数、正确数、用时等
- 关联多个Answer记录

**UserPreferences.swift**
- 存储用户偏好设置
- 默认题目数量、偏好的运算类型等

### 2. 业务逻辑层 (Services)

#### QuestionGenerator.swift
题目生成器，负责根据难度和类型生成数学题目。

**主要功能：**
- `generateQuestions(count:types:difficulty:)` - 批量生成题目
- `generateQuestion(type:difficulty:)` - 生成单个题目
- 支持四种运算类型的题目生成
- 难度级别控制数字范围

**实现细节：**
```swift
private func generateAddition(difficulty: Int) -> Question
private func generateSubtraction(difficulty: Int) -> Question
private func generateMultiplication(difficulty: Int) -> Question
private func generateDivision(difficulty: Int) -> Question
```

#### PracticeManager.swift
练习管理器，处理练习流程和数据持久化。

**主要功能：**
- `startNewSession()` - 开始新的练习会话
- `submitAnswer()` - 提交答案并验证
- `completeSession()` - 完成练习并保存数据
- `recordWrongAnswer()` - 记录错题
- `getWrongAnswers()` - 获取错题列表

**状态管理：**
- 使用`@Published`属性发布状态变化
- 实时更新UI显示

### 3. 用户界面层 (Views)

#### 主要视图组件

**MainTabView.swift**
- 应用的主标签页容器
- 包含五个主要标签：首页、练习、历史、错题、设置

**HomeView.swift**
- 应用首页，提供练习设置和开始入口
- 用户可以选择运算类型、题目数量、难度级别
- 显示今日练习统计

**PracticeView.swift**
- 练习主界面，显示题目和输入框
- 实时显示进度和计时
- 处理用户输入和答案验证

**ResultView.swift**
- 练习结果页面
- 显示本次练习的详细统计
- 提供重新练习和查看错题选项

**HistoryView.swift**
- 历史记录页面
- 展示所有练习会话记录
- 支持按日期、成绩等排序

**MistakesView.swift**
- 错题本页面
- 显示所有错题记录
- 支持错题复习和掌握标记

**SettingsView.swift**
- 设置页面
- 用户偏好配置
- 应用信息和帮助

## 关键技术实现

### 1. SwiftData集成

**应用入口配置：**
```swift
// IQuickCalApp.swift
.modelContainer(for: [
    Question.self,
    Answer.self,
    WrongAnswer.self,
    PracticeSession.self,
    UserPreferences.self
])
```

**数据查询示例：**
```swift
// 使用FetchDescriptor和Predicate进行查询
let descriptor = FetchDescriptor<WrongAnswer>(
    predicate: #Predicate<WrongAnswer> { wrongAnswer in
        wrongAnswer.questionExpression == expression
    }
)
```

### 2. 状态管理

使用`@StateObject`、`@ObservedObject`和`@Published`实现响应式UI：

```swift
@StateObject private var practiceManager = PracticeManager()
@Published var currentQuestion: Question?
@Published var isCompleted = false
```

### 3. 导航结构

采用NavigationStack + TabView的组合：
- TabView管理主要功能模块
- NavigationStack处理页面间导航
- 使用NavigationLink实现页面跳转

### 4. 错误处理

**SwiftData操作错误处理：**
```swift
do {
    try modelContext.save()
} catch {
    print("保存失败: \(error)")
}
```

## 数据流

1. **用户开始练习** → HomeView → PracticeManager.startNewSession()
2. **生成题目** → QuestionGenerator.generateQuestions()
3. **用户答题** → PracticeView → PracticeManager.submitAnswer()
4. **记录结果** → Answer/WrongAnswer模型 → SwiftData持久化
5. **完成练习** → PracticeManager.completeSession() → PracticeSession保存
6. **查看结果** → ResultView显示统计信息

## 性能优化

### 1. 数据模型优化
- 使用合适的数据类型（Int、String、Date等）
- 避免过度的关联关系
- 合理使用索引（通过属性名查询）

### 2. UI性能
- 使用LazyVStack处理大列表
- 适当使用@State和@Binding减少重绘
- 避免在View中进行复杂计算

### 3. 内存管理
- SwiftData自动管理对象生命周期
- 合理使用weak引用避免循环引用
- 及时释放不需要的资源

## 测试策略

### 1. 单元测试
- QuestionGenerator题目生成逻辑测试
- PracticeManager业务逻辑测试
- 数据模型验证测试

### 2. UI测试
- 主要用户流程测试
- 导航功能测试
- 数据展示正确性测试

### 3. 集成测试
- SwiftData数据持久化测试
- 跨视图状态同步测试

## 部署注意事项

### 1. Xcode项目配置
- 确保所有文件都添加到项目中
- 检查Bundle Identifier设置
- 配置Code Signing

### 2. 系统要求
- iOS 17.0+（SwiftData要求）
- 支持iPhone和iPad
- 适配不同屏幕尺寸

### 3. 应用商店准备
- 添加应用图标
- 创建Launch Screen
- 准备应用截图和描述

## 未来扩展方向

1. **功能扩展**
   - 更多运算类型
   - 自定义题目
   - 竞赛模式

2. **技术优化**
   - CloudKit同步
   - Widget支持
   - Apple Watch集成

3. **用户体验**
   - 动画效果
   - 音效反馈
   - 无障碍访问
