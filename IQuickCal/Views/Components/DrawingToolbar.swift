//
//  DrawingToolbar.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/9.
//

import SwiftUI

/// 手写工具栏组件
struct DrawingToolbar: View {
    @ObservedObject var drawingModel: DrawingCanvasModel
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Spacer()
            
            // 中间工具组
            HStack(spacing: 20) {
                // 清除按钮
                Button(action: {
                    drawingModel.clearAll()
                }) {
                    iconButtonContent(
                        icon: "trash",
                        color: .red
                    )
                }
                
                // 画笔粗细选择
                Menu {
                    Button("细笔 (1.5pt)") { drawingModel.setPenWidth(1.5) }
                    Button("中笔 (2.5pt)") { drawingModel.setPenWidth(2.5) }
                    Button("粗笔 (4.0pt)") { drawingModel.setPenWidth(4.0) }
                } label: {
                    iconButtonContent(
                        icon: "pencil.tip",
                        color: .blue
                    )
                }
                
                // 颜色选择
                Menu {
                    Button("黑色") { drawingModel.setPenColor(.black) }
                    Button("蓝色") { drawingModel.setPenColor(.blue) }
                    Button("红色") { drawingModel.setPenColor(.red) }
                    Button("绿色") { drawingModel.setPenColor(.green) }
                } label: {
                    Circle()
                        .fill(drawingModel.selectedColor)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            Spacer()
            
            // 完成按钮（右侧）
            Button(action: onClose) {
                Text("完成")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // 统一的图标按钮样式
    @ViewBuilder
    private func iconButtonContent(icon: String, color: Color) -> some View {
        Image(systemName: icon)
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(color)
            .frame(width: 36, height: 36)
            .background(color.opacity(0.1))
            .clipShape(Circle())
    }
}
