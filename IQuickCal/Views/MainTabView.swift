//
//  MainTabView.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("练习")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("历史")
                }
            
            MistakesView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("错题本")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("设置")
                }
        }
        .accentColor(.blue)
    }
}
