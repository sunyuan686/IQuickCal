//
//  DrawingCanvas.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/9.
//

import SwiftUI

/// 手写画布组件
struct DrawingCanvas: View {
    @ObservedObject var drawingModel: DrawingCanvasModel
    
    var body: some View {
        Canvas { context, size in
            // 绘制已完成的路径
            for path in drawingModel.paths {
                drawPath(context: context, path: path)
            }
            
            // 绘制当前正在绘制的路径
            if drawingModel.isDrawing && !drawingModel.currentPath.points.isEmpty {
                drawPath(context: context, path: drawingModel.currentPath)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    drawingModel.addPoint(value.location)
                }
                .onEnded { _ in
                    drawingModel.finishCurrentPath()
                }
        )
    }
    
    /// 绘制路径
    private func drawPath(context: GraphicsContext, path: DrawingPath) {
        guard path.points.count > 1 else { return }
        
        var cgPath = Path()
        cgPath.move(to: path.points[0])
        
        for i in 1..<path.points.count {
            cgPath.addLine(to: path.points[i])
        }
        
        context.stroke(
            cgPath,
            with: .color(path.color),
            style: StrokeStyle(
                lineWidth: path.lineWidth,
                lineCap: .round,
                lineJoin: .round
            )
        )
    }
}
