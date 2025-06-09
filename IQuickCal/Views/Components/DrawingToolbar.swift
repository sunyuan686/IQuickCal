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
            // 关闭按钮
            Button(action: onClose) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                    Text("关闭")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .clipShape(Capsule())
            }
            
            Spacer()
            
            // 中间工具组
            HStack(spacing: 12) {
                // 清除按钮
                Button(action: {
                    drawingModel.clearAll()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.caption)
                        Text("清除")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
                }
                
                // 画笔粗细选择
                Menu {
                    Button("细笔") { drawingModel.setPenWidth(1.5) }
                    Button("中笔") { drawingModel.setPenWidth(2.5) }
                    Button("粗笔") { drawingModel.setPenWidth(4.0) }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil.tip")
                            .font(.caption)
                        Text("笔触")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
                }
                
                // 颜色选择
                Menu {
                    Button("黑色") { drawingModel.setPenColor(.black) }
                    Button("蓝色") { drawingModel.setPenColor(.blue) }
                    Button("红色") { drawingModel.setPenColor(.red) }
                    Button("绿色") { drawingModel.setPenColor(.green) }
                } label: {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(drawingModel.currentPath.color)
                            .frame(width: 12, height: 12)
                        Text("颜色")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            // 完成按钮（右侧）
            Button(action: onClose) {
                Text("完成")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
