//
//  AdvancedFeaturesDemo.swift
//  Y_SwiftUIAlertExample
//
//  Created by Yue on 2025/8/28.
//

import SwiftUI
import Y_SwiftUIAlert

// MARK: - Y_SwiftUIAlert完整功能测试页面
struct AdvancedFeaturesDemo: View {
    
    // MARK: - 状态管理
    @State private var alertConfig: YAlertConfig?
    @State private var resultMessage = ""
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                    advancedFeaturesSection
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
}

// MARK: - 视图组件
private extension AdvancedFeaturesDemo {
    var advancedFeaturesSection: some View {
        GroupBox("高级功能测试") {
            VStack(spacing: 12) {
                Text("验证规则、异步操作等高级功能")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    Button("Builder创建复杂Alert") {
                        showBuilderAlert()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.pink)
                    
                    Button("Builder多字段表单") {
                        showBuilderFormAlert()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.cyan)
                    
                    Button("验证规则测试") {
                        showValidationAlert()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.green)
                    
                    Button("复杂验证") {
                        showComplexValidationAlert()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.mint)
                    
                    Button("异步单个Alert") {
                        Task {
                            await showAsyncAlert()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.indigo)
                    
                    Button("异步多个Alert") {
                        Task {
                            await showAsyncAlert()
                            await showAsyncAlert2()
                        }
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

// MARK: - Alert展示方法
private extension AdvancedFeaturesDemo {
    
    // MARK: - 高级功能
    func showValidationAlert() {
        do {
            let validation = YValidationRuleSet([
                .required,
                .length(min: 6, max: 20),
                .custom(message: "密码必须包含数字") { text in
                    return text.rangeOfCharacter(from: .decimalDigits) != nil
                }
            ])
            
            let passwordConfig = YTextFieldConfig(
                placeholder: "请输入密码（6-20位，含数字）",
                isSecure: true,
                validationRules: validation
            )
            
            alertConfig = try YAlertConfig.textField(
                title: "密码验证",
                message: "请输入符合要求的密码",
                textFieldConfig: passwordConfig,
                onConfirm: { password in
                    resultMessage = "✅ 验证成功 - 密码长度: \(password.count)"
                },
                onCancel: {
                    resultMessage = "❌ 取消密码验证"
                }
            )
        } catch {
            resultMessage = "❌ 创建验证Alert失败: \(error)"
        }
    }
    
    func showAsyncAlert() async {
        do {
            let config = try YAlertConfig.simple(
                title: "异步Alert",
                message: "这是使用async/await展示的Alert"
            ) {
                resultMessage = "✅ 异步Alert - 操作完成"
            }
            
            let result = await YAlertManager.shared.presentAlert(config)
            
            switch result {
            case .success:
                print("🎯 异步Alert展示成功")
            case .failure(let error):
                resultMessage = "❌ 异步Alert展示失败: \(error.localizedDescription)"
            }
        } catch {
            resultMessage = "❌ 创建异步Alert失败: \(error)"
        }
    }
    
    func showAsyncAlert2() async {
        do {
            let config = try YAlertConfig.simple(
                title: "2异步Alert2",
                message: "这是使用async/await展示的Alert2"
            ) {
                resultMessage = "✅ 异步Alert2 - 操作完成"
            }
            
            let result = await YAlertManager.shared.presentAlert(config)
            
            switch result {
            case .success:
                print("🎯 异步Alert2展示成功")
            case .failure(let error):
                resultMessage = "❌ 异步Alert2展示失败: \(error.localizedDescription)"
            }
        } catch {
            resultMessage = "❌ 创建异步Alert2失败: \(error)"
        }
    }
    
    func showComplexValidationAlert() {
        do {
            let phoneValidation = YValidationRuleSet([
                .required,
                .custom(message: "请输入有效的手机号码") { text in
                    let phoneRegex = "^1[3-9]\\d{9}$"
                    let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
                    return predicate.evaluate(with: text)
                }
            ])
            
            let phoneConfig = YTextFieldConfig(
                placeholder: "请输入手机号码",
                keyboardType: .numberPad,
                validationRules: phoneValidation
            )
            
            alertConfig = try YAlertConfig.textField(
                title: "手机验证",
                message: "请输入11位有效手机号码",
                textFieldConfig: phoneConfig,
                onConfirm: { phone in
                    resultMessage = "✅ 复杂验证 - 手机号: '\(phone)'"
                },
                onCancel: {
                    resultMessage = "❌ 取消手机验证"
                }
            )
        } catch {
            resultMessage = "❌ 创建复杂验证Alert失败: \(error)"
        }
    }
    
    // MARK: - Builder模式
    func showBuilderAlert() {
        do {
            let alert = try YAlertBuilder(title: "Builder示例")
                .message("使用Builder模式创建的复杂Alert")
                .textField(YTextFieldConfig.text(
                    placeholder: "姓名",
                    validation: YValidationRuleSet(.required, .length(min: 2, max: 10))
                ))
                .textField(YTextFieldConfig.number(
                    placeholder: "年龄",
                    allowDecimal: false
                ))
                .confirmButton(title: "提交") { values in
                    let name = values[0]
                    let age = values[1]
                    resultMessage = "✅ Builder - 姓名: '\(name)', 年龄: '\(age)'"
                }
                .cancelButton {
                    resultMessage = "❌ Builder - 取消提交"
                }
                .build()
            
            alertConfig = alert
        } catch {
            resultMessage = "❌ 创建Builder Alert失败: \(error)"
        }
    }
    
    func showBuilderFormAlert() {
        do {
            let alert = try YAlertBuilder(title: "用户注册")
                .message("请填写注册信息")
                .textField(YTextFieldConfig.username())
                .textField(YTextFieldConfig.email())
                .textField(YTextFieldConfig.password())
                .textField(YTextFieldConfig(
                    placeholder: "确认密码",
                    isSecure: true,
                    validationRules: YValidationRuleSet(.required)
                ))
                .confirmButton(title: "注册") { values in
                    resultMessage = "✅ Builder表单 - 用户名: '\(values[0])', 邮箱: '\(values[1])'"
                }
                .cancelButton(title: "取消") {
                    resultMessage = "❌ Builder表单 - 取消注册"
                }
                .style(.alert)
                .build()
            
            alertConfig = alert
        } catch {
            resultMessage = "❌ 创建Builder表单失败: \(error)"
        }
    }
}

#Preview {
    AdvancedFeaturesDemo()
}
