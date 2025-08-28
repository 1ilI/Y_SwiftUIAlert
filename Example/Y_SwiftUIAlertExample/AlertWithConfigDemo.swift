//
//  BaseDemo.swift
//  Y_SwiftUIAlertExample
//
//  Created by Yue on 2025/8/27.
//


import SwiftUI
import Y_SwiftUIAlert

// MARK: - 通过 YAlertConfig 展示 Alert
struct AlertWithConfigDemo: View {
    
    // MARK: - 状态管理
    @State private var alertConfig: YAlertConfig?
    @State private var resultMessage = ""
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                    directUsageSection
                    resultSection
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Y_SwiftUIAlert 示例")
        }
        // 主要YAlert系统
        .yAlert($alertConfig)
    }
    
    var directUsageSection: some View {
        GroupBox("直接使用YAlertConfig") {
            VStack(spacing: 12) {
                Text("使用YAlertConfig直接创建Alert")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    Button("简单Alert") {
                        showSimpleConfigAlert()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("确认Alert") {
                        showConfirmConfigAlert()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("危险Alert") {
                        showDestructiveConfigAlert()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    
                    Button("TextField Alert") {
                        showTextFieldConfigAlert()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.blue)
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

// MARK: - 直接使用YAlertConfig展示
private extension AlertWithConfigDemo {

    func showSimpleConfigAlert() {
        do {
            alertConfig = try YAlertConfig.simple(
                title: "直接Config",
                message: "这是直接使用YAlertConfig.simple创建的Alert",
                confirmTitle: "知道了"
            ) {
                resultMessage = "✅ 直接Config - 简单Alert确认"
            }
        } catch {
            resultMessage = "❌ 创建简单Alert失败: \(error)"
        }
    }
    
    func showConfirmConfigAlert() {
        do {
            alertConfig = try YAlertConfig.confirm(
                title: "确认删除",
                message: "您确定要删除这个项目吗？使用YAlertConfig.confirm创建。",
                onConfirm: {
                    resultMessage = "✅ 直接Config - 确认删除"
                },
                onCancel: {
                    resultMessage = "❌ 直接Config - 取消删除"
                }
            )
        } catch {
            resultMessage = "❌ 创建确认Alert失败: \(error)"
        }
    }
    
    func showDestructiveConfigAlert() {
        do {
            alertConfig = try YAlertConfig.destructive(
                title: "永久删除",
                message: "此操作将永久删除所有数据，无法撤销！",
                onDestructive: {
                    resultMessage = "💥 直接Config - 执行危险操作"
                },
                onCancel: {
                    resultMessage = "🛡️ 直接Config - 取消危险操作"
                }
            )
        } catch {
            resultMessage = "❌ 创建危险Alert失败: \(error)"
        }
    }
    
    func showTextFieldConfigAlert() {
        do {
            let textFieldConfig = YTextFieldConfig.email(
                placeholder: "请输入邮箱地址"
            )
            
            alertConfig = try YAlertConfig.textField(
                title: "设置邮箱",
                message: "请输入您的邮箱地址，我们将发送验证码",
                textFieldConfig: textFieldConfig,
                onConfirm: { email in
                    resultMessage = "✅ 直接Config - 设置邮箱: '\(email)'"
                },
                onCancel: {
                    resultMessage = "❌ 直接Config - 取消设置邮箱"
                }
            )
        } catch {
            resultMessage = "❌ 创建TextField Alert失败: \(error)"
        }
    }
}

#Preview {
    AlertWithConfigDemo()
}
