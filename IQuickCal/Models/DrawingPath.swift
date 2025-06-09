//
//  DrawingPath.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/9.
//

import SwiftUI

/// 手写路径数据模型
struct DrawingPath: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    
    init(points: [CGPoint] = [], color: Color = .black, lineWidth: CGFloat = 2.0) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
    }
}

/// 手写画布状态管理
class DrawingCanvasModel: ObservableObject {
    @Published var paths: [DrawingPath] = []
    @Published var currentPath = DrawingPath()
    @Published var isDrawing = false
    
    // 当前选择的画笔属性
    @Published var selectedColor: Color = .black
    @Published var selectedLineWidth: CGFloat = 2.0
    
    /// 添加点到当前路径
    func addPoint(_ point: CGPoint) {
        // 确保使用当前选择的画笔属性
        if currentPath.points.isEmpty {
            currentPath.color = selectedColor
            currentPath.lineWidth = selectedLineWidth
        }
        currentPath.points.append(point)
        isDrawing = true
    }
    
    /// 完成当前路径绘制
    func finishCurrentPath() {
        if !currentPath.points.isEmpty {
            paths.append(currentPath)
            // 创建新路径时保持当前选择的画笔属性
            currentPath = DrawingPath(color: selectedColor, lineWidth: selectedLineWidth)
        }
        isDrawing = false
    }
    
    /// 清除所有涂鸦
    func clearAll() {
        paths.removeAll()
        currentPath = DrawingPath(color: selectedColor, lineWidth: selectedLineWidth)
        isDrawing = false
    }
    
    /// 设置画笔颜色
    func setPenColor(_ color: Color) {
        selectedColor = color
        currentPath.color = color
    }
    
    /// 设置画笔粗细
    func setPenWidth(_ width: CGFloat) {
        selectedLineWidth = width
        currentPath.lineWidth = width
    }
}
