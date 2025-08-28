//
//  SimpleAlertDemo.swift
//  Y_SwiftUIAlertExample
//
//  Created by Yue on 2025/8/27.
//

import SwiftUI
import Y_SwiftUIAlert

// MARK: - Y_SwiftUIAlert 便利简单方法展示 Alert
struct SimpleAlertDemo: View {
    // MARK: - 状态管理
    @State private var resultMessage = ""
    
    // 便利方法测试状态
    @State private var showSimpleAlert = false
    @State private var showConfirmAlert = false
    @State private var showDestructiveAlert = false
    @State private var showTextFieldAlert = false
    @State private var showMultiTextFieldAlert = false
    @State private var showActionSheet = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    convenienceMethodsSection
                    resultSection
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Y_SwiftUIAlert 示例")
        }
        
        // 便利简单Alert
        .ySimpleAlert("便利方法", isPresented: $showSimpleAlert, message: "这是使用便利方法创建的简单Alert") {
            resultMessage = "✅ 便利方法 - 简单Alert确认"
        }
        
        // 便利确认Alert
        .yConfirmAlert("确认操作", isPresented: $showConfirmAlert, message: "使用便利方法的确认Alert") {
            resultMessage = "✅ 便利方法 - 确认操作"
        } onCancel: {
            resultMessage = "❌ 便利方法 - 取消操作"
        }
        
        // 便利危险Alert
        .yDestructiveAlert("危险操作", isPresented: $showDestructiveAlert, message: "使用便利方法的危险Alert") {
            resultMessage = "💥 便利方法 - 执行危险操作"
        } onCancel: {
            resultMessage = "🛡️ 便利方法 - 取消危险操作"
        }
        
        // 便利TextField
        .yTextFieldAlert("输入名称", isPresented: $showTextFieldAlert, textFieldConfig: YTextFieldConfig.nickname()) { name in
            resultMessage = "✅ 便利方法 - 输入的名称: '\(name)'"
        } onCancel: {
            resultMessage = "❌ 便利方法 - 取消输入"
        }
        
        // 便利多TextField
        .yMultiTextFieldAlert("登录信息", isPresented: $showMultiTextFieldAlert, textFieldConfigs: [
            YTextFieldConfig.username(),
            YTextFieldConfig.password()
        ]) { values in
            resultMessage = "✅ 便利方法 - 用户名: '\(values[0])', 密码: '\(values[1])'"
        } onCancel: {
            resultMessage = "❌ 便利方法 - 取消登录"
        }
        
        // 便利ActionSheet
        .yActionSheet("选择操作", isPresented: $showActionSheet, actions: [
            YAlertAction.normal(title: "选项1") {
                resultMessage = "🔥 便利方法 - 选择了选项1"
            },
            YAlertAction.normal(title: "选项2") {
                resultMessage = "🌟 便利方法 - 选择了选项2"
            },
            YAlertAction.destructive(title: "删除") {
                resultMessage = "💥 便利方法 - 执行删除操作"
            },
            YAlertAction.cancel {
                resultMessage = "❌ 便利方法 - 取消ActionSheet"
            }
        ])
    }
}

// MARK: - 视图组件
private extension SimpleAlertDemo {
    var convenienceMethodsSection: some View {
        GroupBox("便利方法测试") {
            VStack(spacing: 12) {
                Text("使用.ySimpleAlert()等便利方法")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    Button("便利简单Alert") {
                        showSimpleAlert = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("便利确认Alert") {
                        showConfirmAlert = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("便利危险Alert") {
                        showDestructiveAlert = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    
                    Button("便利TextField") {
                        showTextFieldAlert = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.blue)
                    
                    Button("便利多TextField") {
                        showMultiTextFieldAlert = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.purple)
                    
                    Button("便利ActionSheet") {
                        showActionSheet = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.orange)
                }
            }
        }
    }
    
    @ViewBuilder
    var resultSection: some View {
        if !resultMessage.isEmpty {
            GroupBox("操作结果") {
                HStack {
                    Text(resultMessage)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("清除") {
                        resultMessage = ""
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                }
                .padding()
            }
        }
    }
}

#Preview {
    SimpleAlertDemo()
}
