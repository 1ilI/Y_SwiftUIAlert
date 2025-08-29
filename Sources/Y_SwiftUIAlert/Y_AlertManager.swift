//
//  Y_AlertManager.swift
//  Y_SwiftUIAlert
//
//  Created by Yue on 2025.
//

import UIKit
import Foundation

// MARK: - 窗口提供协议（便于测试）
public protocol Y_WindowProviding {
    func getCurrentWindow() -> UIWindow?
    func getTopViewController() -> UIViewController?
}

// MARK: - 默认窗口提供者
public class Y_DefaultWindowProvider: Y_WindowProviding {
    public init() {}
    
    public func getCurrentWindow() -> UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            debugLog("⚠️ 无法获取当前窗口")
            return nil
        }
        return window
    }
    
    public func getTopViewController() -> UIViewController? {
        guard let window = getCurrentWindow(),
              let rootViewController = window.rootViewController else {
            debugLog("⚠️ 无法获取根视图控制器")
            return nil
        }
        
        return getTopViewController(from: rootViewController)
    }
    
    private func getTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return getTopViewController(from: presentedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            return navigationController.visibleViewController ?? navigationController
        }
        
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController.selectedViewController ?? tabBarController
        }
        
        return viewController
    }
}

// MARK: - Alert展示协议
public protocol Y_AlertPresentable {
    func presentAlert(_ config: Y_AlertConfig) async -> Result<Void, Y_AlertError>
    func presentAlert(_ config: Y_AlertConfig, completion: ((Result<Void, Y_AlertError>) -> Void)?)
}

// MARK: - Alert管理器
@MainActor
public class Y_AlertManager: Y_AlertPresentable, ObservableObject {
    public static let shared = Y_AlertManager()
    
    private let windowProvider: Y_WindowProviding
    
    // 当前展示的Alert控制器（用于验证更新）
    private weak var currentAlertController: UIAlertController?
    private var currentConfig: Y_AlertConfig?
    
    // 文本变化回调存储（使用弱引用避免循环引用）
    private var textFieldCallbacks: [WeakTextFieldCallback] = []
    private var validationTimer: Timer?
    
    /// 弱引用TextField回调结构，避免内存泄漏
    /// 注意：callback闭包也可能需要弱引用处理
    private class WeakTextFieldCallback {
        weak var textField: UITextField?
        private let callback: (String) -> Void
        
        init(textField: UITextField, callback: @escaping (String) -> Void) {
            self.textField = textField
            // 使用weakly captured callback避免循环引用
            self.callback = callback
        }
        
        var isValid: Bool {
            return textField != nil
        }
        
        func executeCallback(with text: String) {
            callback(text)
        }
    }
    
    // MARK: - 初始化和清理
    public init(windowProvider: Y_WindowProviding = Y_DefaultWindowProvider()) {
        self.windowProvider = windowProvider
        debugLog("🚀 Y_AlertManager初始化完成")
    }
    
    // MARK: - 公共展示方法
    
    /// 异步展示Alert
    public func presentAlert(_ config: Y_AlertConfig) async -> Result<Void, Y_AlertError> {
        return await withCheckedContinuation { continuation in
            presentAlert(config) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    /// 展示Alert（带完成回调）
    public func presentAlert(_ config: Y_AlertConfig, completion: ((Result<Void, Y_AlertError>) -> Void)? = nil) {
        debugLog("📱 准备展示Alert: '\(config.title)'")
        
        // 获取顶层视图控制器
        guard let topViewController = windowProvider.getTopViewController() else {
            let error = Y_AlertError.noValidWindow
            debugLog("❌ \(error.localizedDescription ?? "窗口获取失败")")
            completion?(.failure(error))
            return
        }
        
        do {
            // 创建UIAlertController
            let alertController = try createAlertController(from: config)
            
            // 存储当前状态
            currentAlertController = alertController
            currentConfig = config
            
            // 展示Alert
            topViewController.present(alertController, animated: true) {
                debugLog("✅ Alert展示成功: '\(config.title)'")
                completion?(.success(()))
            }
            
        } catch {
            let alertError = error as? Y_AlertError ?? Y_AlertError.presentationFailed(underlying: error)
            debugLog("❌ Alert展示失败: \(alertError.localizedDescription ?? "未知错误")")
            completion?(.failure(alertError))
        }
    }
    
    // MARK: - 私有方法
    
    /// 创建UIAlertController
    private func createAlertController(from config: Y_AlertConfig) throws -> UIAlertController {
        // 创建新的AlertController
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: config.style.uiAlertStyle
        )
        
        debugLog("🆕 创建新的UIAlertController")
        
        // 配置基本信息
        alertController.title = config.title
        alertController.message = config.message
        
        // 清空回调存储
        textFieldCallbacks.removeAll()
        
        // 添加TextField
        for (index, textFieldConfig) in config.textFields.enumerated() {
            alertController.addTextField { [weak self] textField in
                self?.configureTextField(textField, with: textFieldConfig, index: index)
            }
        }
        
        // 添加Actions
        for (index, actionConfig) in config.actions.enumerated() {
            let alertAction = UIAlertAction(
                title: actionConfig.title,
                style: actionConfig.style
            ) { [weak self] _ in
                self?.handleActionTapped(actionConfig, alertController: alertController, config: config)
            }
            
            // 如果有TextField且是确认类型的按钮，需要根据验证状态设置启用状态
            if !config.textFields.isEmpty && actionConfig.style == .default {
                alertAction.isEnabled = validateAllTextFields(
                    alertController.textFields ?? [],
                    configs: config.textFields
                )
            }
            
            alertController.addAction(alertAction)
            
            // 设置首选按钮
            if let preferredIndex = config.preferredActionIndex, index == preferredIndex {
                alertController.preferredAction = alertAction
            }
        }
        
        return alertController
    }
    
    /// 配置TextField
    private func configureTextField(_ textField: UITextField, with config: Y_TextFieldConfig, index: Int) {
        debugLog("🔧 配置TextField[\(index)]: '\(config.placeholder)'")
        
        // 基础配置
        textField.placeholder = config.placeholder
        textField.text = config.initialText
        textField.keyboardType = config.keyboardType
        textField.isSecureTextEntry = config.isSecure
        textField.autocapitalizationType = config.autocapitalizationType
        textField.autocorrectionType = config.autocorrectionType
        textField.clearButtonMode = config.clearButtonMode
        textField.returnKeyType = config.returnKeyType
        
        // 外观配置
        if let textColor = config.textColor {
            textField.textColor = textColor
        }
        if let font = config.font {
            textField.font = font
        }
        if let backgroundColor = config.backgroundColor {
            textField.backgroundColor = backgroundColor
        }
        if let borderStyle = config.borderStyle {
            textField.borderStyle = borderStyle
        }
        
        // 执行自定义配置
        config.customConfiguration?(textField)
        
        // 添加标准化的TextField监听（关键改进）
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        
        textField.addTarget(
            self,
            action: #selector(textFieldEditingBegan(_:)),
            for: .editingDidBegin
        )
        
        textField.addTarget(
            self,
            action: #selector(textFieldEditingEnded(_:)),
            for: .editingDidEnd
        )
        
        // 保存自定义回调（使用弱引用避免内存泄漏）
        if let onTextChanged = config.onTextChanged {
            let weakCallback = WeakTextFieldCallback(textField: textField, callback: onTextChanged)
            textFieldCallbacks.append(weakCallback)
        }
    }
    
    // MARK: - TextField事件处理
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        // 清理失效的弱引用并执行自定义回调
        textFieldCallbacks = textFieldCallbacks.filter { $0.isValid }
        
        for callback in textFieldCallbacks {
            if callback.textField === textField {
                callback.executeCallback(with: text)
                break
            }
        }
        
        // 应用字符限制
        if let config = getCurrentTextFieldConfig(for: textField) {
            if let maxLength = config.maxLength, text.count > maxLength {
                textField.text = String(text.prefix(maxLength))
                return
            }
            
            if let allowedCharacters = config.allowedCharacters {
                let filteredText = text.filter { allowedCharacters.contains($0.unicodeScalars.first!) }
                if filteredText != text {
                    textField.text = filteredText
                    return
                }
            }
        }
        
        // 防抖验证更新（性能优化）- 确保Timer及时清理
        validationTimer?.invalidate()
        validationTimer = nil
        validationTimer = Timer.scheduledTimer(withTimeInterval: Y_AlertConstants.validationDebounceTime, repeats: false) { [weak self] timer in
            self?.updateConfirmButtonState()
            // Timer执行完成后立即置空，避免内存泄漏
            self?.validationTimer = nil
        }
        
        debugLog("💬 TextField内容变化: '\(text)'")
    }
    
    @objc private func textFieldEditingBegan(_ textField: UITextField) {
        if let config = getCurrentTextFieldConfig(for: textField) {
            config.onEditingBegan?()
        }
    }
    
    @objc private func textFieldEditingEnded(_ textField: UITextField) {
        if let config = getCurrentTextFieldConfig(for: textField) {
            config.onEditingEnded?()
        }
    }
    
    /// 获取TextField对应的配置
    private func getCurrentTextFieldConfig(for textField: UITextField) -> Y_TextFieldConfig? {
        guard let alertController = currentAlertController,
              let config = currentConfig,
              let textFields = alertController.textFields,
              let index = textFields.firstIndex(of: textField),
              index < config.textFields.count else {
            return nil
        }
        return config.textFields[index]
    }
    
    /// 更新确认按钮状态
    private func updateConfirmButtonState() {
        guard let alertController = currentAlertController,
              let config = currentConfig,
              let textFields = alertController.textFields else {
            debugLog("⚠️ 验证更新失败：缺少必要的引用")
            return
        }
        
        // 找到确认类型的按钮
        let confirmActions = alertController.actions.filter { $0.style == .default }
        
        // 验证所有TextField
        let allValid = validateAllTextFields(textFields, configs: config.textFields)
        
        // 更新按钮状态
        confirmActions.forEach { action in
            action.isEnabled = allValid
        }
        
        debugLog("🔍 验证结果: \(allValid ? "通过" : "失败")")
    }
    
    /// 验证所有TextField
    private func validateAllTextFields(_ textFields: [UITextField], configs: [Y_TextFieldConfig]) -> Bool {
        guard textFields.count == configs.count else {
            return false
        }
        
        for (textField, config) in zip(textFields, configs) {
            if !validateSingleTextField(textField, with: config) {
                return false
            }
        }
        
        return true
    }
    
    /// 验证单个TextField
    private func validateSingleTextField(_ textField: UITextField, with config: Y_TextFieldConfig) -> Bool {
        let text = textField.text ?? ""
        
        guard let validationRules = config.validationRules else {
            return true // 没有验证规则认为有效
        }
        
        let result = validationRules.validate(text)
        debugLog("🔍 验证TextField: '\(text)' - 结果: \(result.isValid ? "通过" : "失败")")
        
        if let errorMessage = result.errorMessage {
            debugLog("❌ 验证错误: \(errorMessage)")
        }
        
        return result.isValid
    }
    
    /// 处理Action点击
    private func handleActionTapped(_ action: Y_AlertAction, alertController: UIAlertController, config: Y_AlertConfig) {
        debugLog("🎯 用户点击: '\(action.title)'")
        
        // 立即清理Timer，避免内存泄漏
        validationTimer?.invalidate()
        validationTimer = nil
        
        // 获取TextField值
        let textFieldValues = alertController.textFields?.map { $0.text ?? "" } ?? []
        if !textFieldValues.isEmpty {
            debugLog("📝 TextField值: \(textFieldValues)")
        }
        
        // 执行Action
        action.execute(with: textFieldValues)
        
        // 强制资源清理，确保内存及时释放
        cleanupResources()
    }
    
    /// 清理所有Alert相关资源，防止内存泄漏
    private func cleanupResources() {
        currentAlertController = nil
        currentConfig = nil
        textFieldCallbacks.removeAll()
        validationTimer?.invalidate()
        validationTimer = nil
        debugLog("🧹 清理所有Alert相关资源，防止内存泄漏")
    }
}

// MARK: - Alert 管理器 打印调试
public extension Y_AlertManager {
    /// 静态调试开关 - 控制是否输出调试日志
    nonisolated(unsafe) static var logEnabled: Bool = false
    
    /// 开启调试日志输出
    nonisolated public static func enableDebugLog() {
        Y_AlertManager.logEnabled = true
    }
    
    /// 关闭调试日志输出
    nonisolated public static func disableDebugLog() {
        Y_AlertManager.logEnabled = false
    }
}

// MARK: - 条件编译的日志函数（全局）
#if DEBUG
internal func debugLog(_ message: String) {
    if Y_AlertManager.logEnabled {
        print("🎯 YAlert: \(message)")
    }
}
#else
internal func debugLog(_ message: String) {}
#endif
