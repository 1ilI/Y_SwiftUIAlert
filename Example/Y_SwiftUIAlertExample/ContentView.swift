//
//  ContentView.swift
//  Y_SwiftUIAlertExample
//
//  Created by Yue on 2025.
//

import SwiftUI
import Y_SwiftUIAlert

// MARK: - Y_SwiftUIAlert完整功能测试页面
struct ContentView: View {
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 40) {
                    Spacer()
                    
                    NavigationLink(destination: AlertWithConfigDemo()) {
                        Text("通过 YAlertConfig 展示 Alert")
                    }

                    NavigationLink(destination: SimpleAlertDemo()) {
                        Text("便利简单方法展示 Alert")
                    }
                    
                    NavigationLink(destination: AdvancedFeaturesDemo()) {
                        Text("高级功能展示 Alert")
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Y_SwiftUIAlert 示例")
            .task {
                // 开启打印输出
                YAlertManager.enableDebugLog()
            }
        }
    }
}

#Preview {
    ContentView()
}
