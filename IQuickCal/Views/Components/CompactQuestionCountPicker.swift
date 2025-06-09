//
//  CompactQuestionCountPicker.swift
//  IQuickCal
//
//  Created by GitHub Copilot on 2025/6/9.
//

import SwiftUI

struct CompactQuestionCountPicker: View {
    @Binding var selectedCount: Int
    
    private let availableCounts = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
    
    init(selectedCount: Binding<Int>) {
        self._selectedCount = selectedCount
    }
    
    var body: some View {
        inlineWheelPicker
    }
    
    private var inlineWheelPicker: some View {
        GeometryReader { geometry in
            let itemHeight: CGFloat = 22
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        // 顶部填充空间
                        Color.clear.frame(height: itemHeight / 2)
                        
                        ForEach(Array(availableCounts.enumerated()), id: \.offset) { index, count in
                            inlineWheelItem(
                                count: count,
                                itemHeight: itemHeight,
                                geometry: geometry
                            )
                            .id("item_\(count)")
                        }
                        
                        // 底部填充空间
                        Color.clear.frame(height: itemHeight / 2)
                    }
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: .constant("item_\(selectedCount)"))
                .onAppear {
                    // 初始滚动到选中项
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo("item_\(selectedCount)", anchor: .center)
                    }
                }
            }
        }
        .frame(width: 70, height: 44)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray3), lineWidth: 0.5)
                )
        )
        .overlay(
            // 中心选择指示器
            RoundedRectangle(cornerRadius: 4)
                .stroke(.blue.opacity(0.3), lineWidth: 1)
                .frame(height: 20)
                .allowsHitTesting(false),
            alignment: .center
        )
        .clipped()
    }
    
    private func inlineWheelItem(count: Int, itemHeight: CGFloat, geometry: GeometryProxy) -> some View {
        GeometryReader { itemGeometry in
            let midY = itemGeometry.frame(in: .global).midY
            let containerMidY = geometry.frame(in: .global).midY
            let distance = abs(midY - containerMidY)
            let normalizedDistance = min(distance / (itemHeight * 1.0), 1.0)
            
            // 计算效果参数
            let scale = 1.0 - (normalizedDistance * 0.15)
            let opacity = 1.0 - (normalizedDistance * 0.5)
            
            Button(action: {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                    selectedCount = count
                    
                    // 触觉反馈
                    if #available(iOS 17.0, *) {
                        let feedback = UIImpactFeedbackGenerator(style: .light)
                        feedback.impactOccurred()
                    }
                }
            }) {
                Text("\(count)")
                    .font(.system(size: 15, weight: selectedCount == count ? .semibold : .medium, design: .rounded))
                    .foregroundColor(selectedCount == count ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: itemHeight)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .animation(.interpolatingSpring(stiffness: 400, damping: 35), value: selectedCount)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(height: itemHeight)
    }

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var selectedCount = 20
        
        var body: some View {
            VStack(spacing: 30) {
                Text("紧凑题量选择器")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack {
                    Text("每组题目数量")
                        .font(.headline)
                    
                    Spacer()
                    
                    CompactQuestionCountPicker(selectedCount: $selectedCount)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Text("当前选择: \(selectedCount)题")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
}
