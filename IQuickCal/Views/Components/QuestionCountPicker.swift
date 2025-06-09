//
//  QuestionCountPicker.swift
//  IQuickCal
//
//  Created by GitHub Copilot on 2025/6/4.
//

import SwiftUI

struct QuestionCountPicker: View {
    @Binding var selectedCount: Int
    let availableCounts: [Int]
    let showDefaultOption: Bool
    let defaultCount: Int?
    
    // 为wheel picker使用的状态
    @State private var pickerSelection: Int
    
    init(selectedCount: Binding<Int>, availableCounts: [Int] = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50], showDefaultOption: Bool = true, defaultCount: Int? = nil) {
        self._selectedCount = selectedCount
        self.availableCounts = availableCounts
        self.showDefaultOption = showDefaultOption
        self.defaultCount = defaultCount
        self._pickerSelection = State(initialValue: selectedCount.wrappedValue)
    }
    
    var pickerOptions: [PickerOption] {
        var options: [PickerOption] = []
        
        // 添加默认选项（如果启用）
        if showDefaultOption, let defaultCount = defaultCount {
            options.append(PickerOption(value: -1, displayText: "默认 (\(defaultCount)题)", isDefault: true))
        }
        
        // 添加固定数量选项
        for count in availableCounts {
            options.append(PickerOption(value: count, displayText: "\(count)题", isDefault: false))
        }
        
        return options
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 使用iPhone样式的wheel picker
            Picker("题目数量", selection: $pickerSelection) {
                ForEach(pickerOptions, id: \.value) { option in
                    Text(option.displayText)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(option.isDefault ? .blue : .primary)
                        .tag(option.value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            .clipped()
            .onChange(of: pickerSelection) { _, newValue in
                if newValue == -1, let defaultCount = defaultCount {
                    // 选择默认选项时，使用推荐数量
                    selectedCount = defaultCount
                } else {
                    // 选择具体数量
                    selectedCount = newValue
                }
            }
            .onAppear {
                // 初始化picker选择
                if selectedCount == defaultCount && showDefaultOption {
                    pickerSelection = -1
                } else {
                    pickerSelection = selectedCount
                }
            }
        }
    }
}

struct PickerOption {
    let value: Int
    let displayText: String
    let isDefault: Bool
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var selectedCount = 20
        
        var body: some View {
            VStack(spacing: 30) {
                Text("选择题目数量")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("当前选择: \(selectedCount)题")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                QuestionCountPicker(
                    selectedCount: $selectedCount,
                    showDefaultOption: true,
                    defaultCount: 25
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding()
                
                Spacer()
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
