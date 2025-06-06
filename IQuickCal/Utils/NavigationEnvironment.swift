//
//  NavigationEnvironment.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import SwiftUI

// 导航控制器，用于管理深层导航的返回
class NavigationController: ObservableObject {
    @Published var dismissToRoot = false
    
    func returnToHome() {
        dismissToRoot = true
    }
}

// Environment Key for NavigationController
struct NavigationControllerKey: EnvironmentKey {
    static let defaultValue = NavigationController()
}

extension EnvironmentValues {
    var navigationController: NavigationController {
        get { self[NavigationControllerKey.self] }
        set { self[NavigationControllerKey.self] = newValue }
    }
}
