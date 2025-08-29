//
//  Y_SwiftUIAlertTests.swift
//  Y_SwiftUIAlert
//
//  Created by Yue on 2025.
//

import XCTest
@testable import Y_SwiftUIAlert

// MARK: - Mock对象
class MockWindowProvider: Y_WindowProviding {
    var shouldReturnNil = false
    
    func getCurrentWindow() -> UIWindow? {
        return shouldReturnNil ? nil : UIWindow()
    }
    
    func getTopViewController() -> UIViewController? {
        return shouldReturnNil ? nil : UIViewController()
    }
}

// MARK: - 主要测试类
final class Y_SwiftUIAlertTests: XCTestCase {
    
    var mockWindowProvider: MockWindowProvider!
    var alertManager: Y_AlertManager!
    
    override func setUpWithError() throws {
        mockWindowProvider = MockWindowProvider()
        alertManager = Y_AlertManager(windowProvider: mockWindowProvider)
    }
    
    override func tearDownWithError() throws {
        mockWindowProvider = nil
        alertManager = nil
    }
    
    // MARK: - 常量测试
    func testConstants() throws {
        XCTAssertEqual(Y_AlertConstants.defaultAnimationDuration, 0.3)
        XCTAssertEqual(Y_AlertConstants.maxTextFieldCount, 5)
        XCTAssertEqual(Y_AlertConstants.DefaultTitles.confirm, "确定")
        XCTAssertEqual(Y_AlertConstants.DefaultTitles.cancel, "取消")
    }
    
    // MARK: - 验证规则测试
    func testValidationRules() throws {
        // 必填验证
        let requiredRule = YValidationRule.required
        XCTAssertTrue(requiredRule.validator("test").isValid)
        XCTAssertFalse(requiredRule.validator("").isValid)
        XCTAssertFalse(requiredRule.validator("   ").isValid)
        
        // 长度验证
        let lengthRule = YValidationRule.length(min: 3, max: 10)
        XCTAssertTrue(lengthRule.validator("test").isValid)
        XCTAssertFalse(lengthRule.validator("ab").isValid)
        XCTAssertFalse(lengthRule.validator("this is too long").isValid)
        
        // 邮箱验证
        let emailRule = YValidationRule.email
        XCTAssertTrue(emailRule.validator("test@example.com").isValid)
        XCTAssertFalse(emailRule.validator("invalid-email").isValid)
        
        // 数字验证
        let numericRule = YValidationRule.numeric
        XCTAssertTrue(numericRule.validator("123").isValid)
        XCTAssertTrue(numericRule.validator("123.45").isValid)
        XCTAssertFalse(numericRule.validator("abc").isValid)
    }
    
    // MARK: - 验证规则集合测试
    func testValidationRuleSet() throws {
        let ruleSet = Y_ValidationRuleSet([
            .required,
            .length(min: 5, max: 20),
            .email
        ])
        
        // 有效邮箱
        XCTAssertTrue(ruleSet.validate("test@example.com").isValid)
        
        // 太短
        XCTAssertFalse(ruleSet.validate("a@b.c").isValid)
        
        // 空值
        XCTAssertFalse(ruleSet.validate("").isValid)
        
        // 非邮箱格式
        XCTAssertFalse(ruleSet.validate("this is not email").isValid)
    }
    
    // MARK: - AlertAction测试
    func testAlertActionCreation() throws {
        // 普通Action
        let normalAction = Y_AlertAction.normal(title: "确定") {
            // 测试回调
        }
        XCTAssertEqual(normalAction.title, "确定")
        XCTAssertEqual(normalAction.style, .default)
        
        // TextField Action
        let textFieldAction = Y_AlertAction.textField(title: "提交") { values in
            // 测试回调
        }
        XCTAssertEqual(textFieldAction.title, "提交")
        XCTAssertEqual(textFieldAction.style, .default)
        
        // 危险Action
        let destructiveAction = Y_AlertAction.destructive(title: "删除") {
            // 测试回调
        }
        XCTAssertEqual(destructiveAction.title, "删除")
        XCTAssertEqual(destructiveAction.style, .destructive)
        
        // 取消Action
        let cancelAction = Y_AlertAction.cancel(title: "取消") {
            // 测试回调
        }
        XCTAssertEqual(cancelAction.title, "取消")
        XCTAssertEqual(cancelAction.style, .cancel)
    }
    
    // MARK: - TextField配置测试
    func testTextFieldConfig() throws {
        let config = Y_TextFieldConfig.text(
            placeholder: "请输入",
            validation: Y_ValidationRuleSet(.required, .length(min: 3, max: 20))
        )
        
        XCTAssertEqual(config.placeholder, "请输入")
        XCTAssertNotNil(config.validationRules)
        XCTAssertTrue(config.validateOnChange)
        
        // 密码配置
        let passwordConfig = Y_TextFieldConfig.password()
        XCTAssertTrue(passwordConfig.isSecure)
        XCTAssertEqual(passwordConfig.autocapitalizationType, .none)
        XCTAssertEqual(passwordConfig.autocorrectionType, .no)
        
        // 邮箱配置
        let emailConfig = Y_TextFieldConfig.email()
        XCTAssertEqual(emailConfig.keyboardType, .emailAddress)
        XCTAssertNotNil(emailConfig.validationRules)
    }
    
    // MARK: - Alert配置测试
    func testAlertConfigCreation() throws {
        // 简单Alert
        let simpleAlert = try Y_AlertConfig.simple(
            title: "提示",
            message: "这是一个测试"
        )
        XCTAssertEqual(simpleAlert.title, "提示")
        XCTAssertEqual(simpleAlert.message, "这是一个测试")
        XCTAssertEqual(simpleAlert.actions.count, 1)
        XCTAssertEqual(simpleAlert.textFields.count, 0)
        
        // 确认Alert
        let confirmAlert = try Y_AlertConfig.confirm(
            title: "确认",
            message: "您确定要执行此操作吗？",
            onConfirm: {}
        )
        XCTAssertEqual(confirmAlert.title, "确认")
        XCTAssertEqual(confirmAlert.actions.count, 2)
        XCTAssertEqual(confirmAlert.preferredActionIndex, 1)
        
        // TextField Alert
        let textFieldConfig = Y_TextFieldConfig.text(placeholder: "请输入")
        let textFieldAlert = try Y_AlertConfig.textField(
            title: "输入",
            textFieldConfig: textFieldConfig,
            onConfirm: { _ in }
        )
        XCTAssertEqual(textFieldAlert.textFields.count, 1)
        XCTAssertEqual(textFieldAlert.actions.count, 2)
    }
    
    // MARK: - Alert配置验证测试
    func testAlertConfigValidation() throws {
        // 测试Action数量限制
        var actions: [Y_AlertAction] = []
        for i in 0...Y_AlertConstants.maxActionCount {
            actions.append(Y_AlertAction.normal(title: "Action \(i)") {})
        }
        
        XCTAssertThrowsError(try Y_AlertConfig(
            title: "测试",
            actions: actions
        )) { error in
            if case Y_AlertError.tooManyActions(let count, let max) = error {
                XCTAssertEqual(count, Y_AlertConstants.maxActionCount + 1)
                XCTAssertEqual(max, Y_AlertConstants.maxActionCount)
            } else {
                XCTFail("Expected tooManyActions error")
            }
        }
        
        // 测试TextField数量限制
        var textFields: [Y_TextFieldConfig] = []
        for i in 0...Y_AlertConstants.maxTextFieldCount {
            textFields.append(Y_TextFieldConfig.text(placeholder: "Field \(i)"))
        }
        
        XCTAssertThrowsError(try Y_AlertConfig(
            title: "测试",
            textFields: textFields,
            actions: [Y_AlertAction.normal(title: "确定") {}]
        )) { error in
            if case Y_AlertError.tooManyTextFields(let count, let max) = error {
                XCTAssertEqual(count, Y_AlertConstants.maxTextFieldCount + 1)
                XCTAssertEqual(max, Y_AlertConstants.maxTextFieldCount)
            } else {
                XCTFail("Expected tooManyTextFields error")
            }
        }
    }
    
    // MARK: - AlertManager测试
    func testAlertManagerPresentationFailure() async throws {
        // 模拟无有效窗口的情况
        mockWindowProvider.shouldReturnNil = true
        
        let config = try Y_AlertConfig.simple(title: "测试")
        let result = await alertManager.presentAlert(config)
        
        switch result {
        case .failure(let error):
            if case Y_AlertError.noValidWindow = error {
                // 期望的错误类型
                XCTAssert(true)
            } else {
                XCTFail("Expected noValidWindow error, got: \(error)")
            }
        case .success:
            XCTFail("Expected failure, got success")
        }
    }
    
    // MARK: - Builder模式测试
    func testAlertBuilder() throws {
        let alert = try Y_AlertBuilder(title: "测试Builder")
            .message("这是使用Builder创建的Alert")
            .textField(Y_TextFieldConfig.text(placeholder: "输入1"))
            .textField(Y_TextFieldConfig.text(placeholder: "输入2"))
            .confirmButton(title: "提交") { values in
                // 处理提交
            }
            .cancelButton()
            .style(.alert)
            .build()
        
        XCTAssertEqual(alert.title, "测试Builder")
        XCTAssertEqual(alert.message, "这是使用Builder创建的Alert")
        XCTAssertEqual(alert.textFields.count, 2)
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.style, .alert)
    }
    
    // MARK: - 国际化测试
    func testLocalization() throws {
        // 测试本地化字符串是否正确加载
        XCTAssertFalse(Y_AlertLocalizable.confirm.isEmpty)
        XCTAssertFalse(Y_AlertLocalizable.cancel.isEmpty)
        XCTAssertFalse(Y_AlertLocalizable.delete.isEmpty)
        
        // 测试格式化字符串
        let lengthMessage = Y_AlertLocalizable.validationLength(min: 3, max: 20)
        XCTAssertTrue(lengthMessage.contains("3"))
        XCTAssertTrue(lengthMessage.contains("20"))
    }
    
    // MARK: - 性能测试
    func testPerformance() throws {
        measure {
            // 测试大量验证规则的性能
            let ruleSet = Y_ValidationRuleSet([
                .required,
                .length(min: 3, max: 100),
                .email,
                .custom { text in
                    return text.count > 5 ? .valid : .invalid(message: "Too short")
                }
            ])
            
            for i in 0..<1000 {
                let testText = "test@example.com\(i)"
                _ = ruleSet.validate(testText)
            }
        }
    }
}
