//
//  CompactQuestionCountPicker.swift
//  IQuickCal
//
//  Created by GitHub Copilot on 2025/6/9.
//

import SwiftUI

struct CompactQuestionCountPicker: View {
    @Binding var selectedCount: Int
    @State private var isExpanded = false
    
    private let availableCounts = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
    
    var body: some View {
        VStack {
            if isExpanded {
                // 展开状态：显示苹果风格的3D滚轮选择器
                expandedPicker
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)).combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .scale(scale: 0.95)).combined(with: .move(edge: .top))
                    ))
            } else {
                // 紧凑状态：显示当前值和箭头
                compactView
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 1.05)),
                        removal: .opacity.combined(with: .scale(scale: 0.95))
                    ))
            }
        }
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: isExpanded)
    }
    
    private var compactView: some View {
        Button(action: {
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                isExpanded.toggle()
            }
        }) {
            HStack(spacing: 8) {
                Text("\(selectedCount)题")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.blue)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.interpolatingSpring(stiffness: 400, damping: 25), value: isExpanded)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.08))
                    .overlay(
                        Capsule()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isExpanded)
    }
    
    private var expandedPicker: some View {
        VStack(spacing: 16) {
            // 只保留关闭按钮，去掉标题
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                        isExpanded = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
            }
            
            // 苹果风格轮盘选择器
            wheelPicker
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.quaternary, lineWidth: 0.5)
        )
        .frame(maxWidth: 300)
    }
    
    private var wheelPicker: some View {
        VStack(spacing: 0) {
            // 渐变遮罩层（顶部）
            LinearGradient(
                colors: [.clear, .black.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 30)
            .allowsHitTesting(false)
            
            // 滚轮主体
            GeometryReader { geometry in
                let itemHeight: CGFloat = 44
                let visibleItems = 5
                let totalHeight = CGFloat(visibleItems) * itemHeight
                
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            // 顶部填充空间
                            Color.clear.frame(height: itemHeight * 2)
                            
                            ForEach(Array(availableCounts.enumerated()), id: \.offset) { index, count in
                                wheelItem(
                                    count: count, 
                                    itemHeight: itemHeight,
                                    totalHeight: totalHeight,
                                    geometry: geometry
                                )
                                .id("item_\(count)")
                            }
                            
                            // 底部填充空间
                            Color.clear.frame(height: itemHeight * 2)
                        }
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: .constant("item_\(selectedCount)"))
                    .onAppear {
                        // 初始滚动到选中项
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                                proxy.scrollTo("item_\(selectedCount)", anchor: .center)
                            }
                        }
                    }
                }
            }
            .frame(height: 220)
            .clipped()
            
            // 渐变遮罩层（底部）
            LinearGradient(
                colors: [.black.opacity(0.1), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 30)
            .allowsHitTesting(false)
        }
        .overlay(
            // 中心选择指示器
            RoundedRectangle(cornerRadius: 8)
                .stroke(.quaternary, lineWidth: 1)
                .frame(height: 44)
                .allowsHitTesting(false),
            alignment: .center
        )
    }
    
    private func wheelItem(count: Int, itemHeight: CGFloat, totalHeight: CGFloat, geometry: GeometryProxy) -> some View {
        GeometryReader { itemGeometry in
            let midY = itemGeometry.frame(in: .global).midY
            let containerMidY = geometry.frame(in: .global).midY
            let distance = abs(midY - containerMidY)
            let normalizedDistance = min(distance / (itemHeight * 1.5), 1.0)
            
            // 计算3D效果参数
            let scale = 1.0 - (normalizedDistance * 0.2)
            let opacity = 1.0 - (normalizedDistance * 0.6)
            let rotationAngle = normalizedDistance * 15 // 3D旋转角度
            
            Button(action: {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                    selectedCount = count
                    
                    // 触觉反馈
                    if #available(iOS 17.0, *) {
                        let feedback = UIImpactFeedbackGenerator(style: .light)
                        feedback.impactOccurred()
                    }
                    
                    // 延迟关闭
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                            isExpanded = false
                        }
                    }
                }
            }) {
                Text("\(count)题")
                    .font(.system(size: 18, weight: selectedCount == count ? .semibold : .regular))
                    .foregroundColor(selectedCount == count ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: itemHeight)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotation3DEffect(
                        .degrees(rotationAngle),
                        axis: (x: 1, y: 0, z: 0),
                        perspective: 0.5
                    )
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
