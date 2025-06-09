//
//  DrawingOverlayView.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/9.
//

import SwiftUI

/// 手写功能透明覆盖层
struct DrawingOverlayView: View {
    @StateObject private var drawingModel = DrawingCanvasModel()
    @Binding var isVisible: Bool
    
    // 题目信息
    let questionExpression: String
    let questionType: QuestionType
    let currentQuestionIndex: Int
    let totalQuestions: Int
    
    // 用于跟踪题目变化的状态
    @State private var lastQuestionIndex: Int = -1
    @State private var viewId: String = ""
    
    var body: some View {
        if isVisible {
            ZStack {
                // 全屏半透明画布背景
                Color.white.opacity(0.95)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部安全区域
                    Color.clear
                        .frame(height: 0)
                        .ignoresSafeArea(.container, edges: .top)
                    
                    // 题目信息展示区域
                    questionInfoSection
                        .background(
                            Color.white.opacity(0.98)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        )
                    
                    // 顶部工具栏
                    DrawingToolbar(drawingModel: drawingModel) {
                        isVisible = false
                    }
                    .padding(.top, 8)
                    .background(
                        Color.white.opacity(0.9)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    )
                    
                    // 全屏手写画布
                    DrawingCanvas(drawingModel: drawingModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.95))
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .animation(.easeInOut(duration: 0.3), value: isVisible)
            .id(viewId)  // 使用动态viewId强制重新创建视图
            .onChange(of: currentQuestionIndex) { oldValue, newValue in
                // 当题目索引变化时，自动清空画布并更新viewId
                print("题目索引变化: \(oldValue) -> \(newValue), lastQuestionIndex: \(lastQuestionIndex)")
                if newValue != lastQuestionIndex {
                    // 立即清空画布
                    DispatchQueue.main.async {
                        drawingModel.clearAll()
                        lastQuestionIndex = newValue
                        viewId = "drawing-\(newValue)-\(UUID().uuidString)"
                        print("画布已清空，更新lastQuestionIndex为: \(newValue), viewId: \(viewId)")
                    }
                }
            }
            .onAppear {
                // 每次视图出现时都检查是否需要清空画布
                print("DrawingOverlayView onAppear, currentQuestionIndex: \(currentQuestionIndex), lastQuestionIndex: \(lastQuestionIndex)")
                
                // 初始化viewId或者强制更新
                if viewId.isEmpty || lastQuestionIndex != currentQuestionIndex {
                    DispatchQueue.main.async {
                        drawingModel.clearAll()
                        lastQuestionIndex = currentQuestionIndex
                        viewId = "drawing-\(currentQuestionIndex)-\(UUID().uuidString)"
                        print("onAppear时清空画布，设置lastQuestionIndex为: \(currentQuestionIndex), viewId: \(viewId)")
                    }
                }
            }
            .onChange(of: isVisible) { oldValue, newValue in
                // 当覆盖层可见性变化时也执行清理检查
                if newValue && !oldValue {
                    print("覆盖层显示，当前题目索引: \(currentQuestionIndex), lastQuestionIndex: \(lastQuestionIndex)")
                    if lastQuestionIndex != currentQuestionIndex {
                        DispatchQueue.main.async {
                            drawingModel.clearAll()
                            lastQuestionIndex = currentQuestionIndex
                            viewId = "drawing-\(currentQuestionIndex)-\(UUID().uuidString)"
                            print("覆盖层显示时清空画布，设置lastQuestionIndex为: \(currentQuestionIndex)")
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var questionInfoSection: some View {
        VStack(spacing: 16) {
            // 题型和进度信息
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(questionType.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("第 \(currentQuestionIndex + 1) 题 / 共 \(totalQuestions) 题")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // 题目表达式
            VStack(spacing: 8) {
                Text(questionExpression)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("=")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.secondary)
                
                Text("?")
                    .font(.system(size: 24, weight: .semibold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(minWidth: 120)
                    .padding(.bottom, 2)
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.orange),
                        alignment: .bottom
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        
        Text("背景内容")
            .font(.title)
        
        DrawingOverlayView(
            isVisible: .constant(true),
            questionExpression: "125 × 3",
            questionType: .twoDigitMultiplication,
            currentQuestionIndex: 2,
            totalQuestions: 10
        )
    }
}
