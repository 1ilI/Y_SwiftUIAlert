//
//  Y_AlertModifier.swift
//  Y_SwiftUIAlert
//
//  Created by Yue on 2025.
//

import SwiftUI

// MARK: - SwiftUI View扩展
public extension View {
    
    /// 使用Y_AlertManager展示Alert
    /// - Parameter config: Alert配置的绑定值，当有值时自动展示Alert
    func y_alert(_ config: Binding<Y_AlertConfig?>) -> some View {
        modifier(Y_AlertModifier(config: config))
    }
    
    /// 使用自定义AlertManager展示Alert
    /// - Parameters:
    ///   - config: Alert配置的绑定值
    ///   - manager: 自定义的AlertManager
    func y_alert(_ config: Binding<Y_AlertConfig?>, manager: Y_AlertManager) -> some View {
        modifier(Y_AlertModifier(config: config, manager: manager))
    }
}

// MARK: - Alert修饰符实现
public struct Y_AlertModifier: ViewModifier {
    @Binding var config: Y_AlertConfig?
    let manager: Y_AlertManager
    
    public init(config: Binding<Y_AlertConfig?>, manager: Y_AlertManager = .shared) {
        self._config = config
        self.manager = manager
    }
    
    public func body(content: Content) -> some View {
        content
            .onChange(of: config) { newConfig in
                if let alertConfig = newConfig {
                    presentAlert(alertConfig)
                }
            }
    }
    
    private func presentAlert(_ alertConfig: Y_AlertConfig) {
        debugLog("📱 SwiftUI触发Alert展示: '\(alertConfig.title)'")
        
        manager.presentAlert(alertConfig) { result in
            switch result {
            case .success:
                debugLog("✅ Alert展示成功")
            case .failure(let error):
                debugLog("❌ Alert展示失败: \(error.localizedDescription ?? "未知错误")")
            }
            
            // 重置配置以避免重复展示
            DispatchQueue.main.async {
                self.config = nil
            }
        }
    }
}

// MARK: - 缓存Alert修饰符（避免重复创建）
public struct CachedAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let configFactory: () -> Y_AlertConfig?
    let manager: Y_AlertManager
    
    @State private var cachedConfig: Y_AlertConfig?
    
    public init(
        isPresented: Binding<Bool>,
        configFactory: @escaping () -> Y_AlertConfig?,
        manager: Y_AlertManager = .shared
    ) {
        self._isPresented = isPresented
        self.configFactory = configFactory
        self.manager = manager
    }
    
    public func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { shouldPresent in
                if shouldPresent {
                    // 只在需要时创建配置，避免重复创建
                    if cachedConfig == nil {
                        cachedConfig = configFactory()
                        debugLog("🎯 缓存Alert配置创建: '\(cachedConfig?.title ?? "未知")'")
                    }
                    
                    if let alertConfig = cachedConfig {
                        presentAlert(alertConfig)
                    }
                }
            }
    }
    
    private func presentAlert(_ alertConfig: Y_AlertConfig) {
        debugLog("📱 SwiftUI触发Alert展示: '\(alertConfig.title)'")
        
        manager.presentAlert(alertConfig) { result in
            switch result {
            case .success:
                debugLog("✅ Alert展示成功")
            case .failure(let error):
                debugLog("❌ Alert展示失败: \(error.localizedDescription ?? "未知错误")")
            }
            
            // 清理缓存并重置状态
            DispatchQueue.main.async {
                self.cachedConfig = nil
                self.isPresented = false
            }
        }
    }
}

// MARK: - 便利方法扩展
public extension View {
    
    /// 简单Alert - 只显示消息
    /// - Parameters:
    ///   - title: Alert标题
    ///   - isPresented: 控制Alert显示的绑定值
    ///   - message: Alert消息（可选）
    ///   - confirmTitle: 确认按钮标题
    ///   - onConfirm: 确认按钮回调
    func y_simpleAlert(
        _ title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        confirmTitle: String = Y_AlertConstants.DefaultTitles.confirm,
        onConfirm: (() -> Void)? = nil
    ) -> some View {
        
        return self.modifier(CachedAlertModifier(
            isPresented: isPresented,
            configFactory: {
                try? Y_AlertConfig.simple(
                    title: title,
                    message: message,
                    confirmTitle: confirmTitle,
                    onConfirm: {
                        onConfirm?()
                        isPresented.wrappedValue = false
                    }
                )
            }
        ))
    }
    
    /// 确认Alert - 确认/取消两个按钮
    /// - Parameters:
    ///   - title: Alert标题
    ///   - isPresented: 控制Alert显示的绑定值
    ///   - message: Alert消息（可选）
    ///   - confirmTitle: 确认按钮标题
    ///   - cancelTitle: 取消按钮标题
    ///   - onConfirm: 确认按钮回调
    ///   - onCancel: 取消按钮回调
    func y_confirmAlert(
        _ title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        confirmTitle: String = Y_AlertConstants.DefaultTitles.confirm,
        cancelTitle: String = Y_AlertConstants.DefaultTitles.cancel,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        
        return self.modifier(CachedAlertModifier(
            isPresented: isPresented,
            configFactory: {
                try? Y_AlertConfig.confirm(
                    title: title,
                    message: message,
                    confirmTitle: confirmTitle,
                    cancelTitle: cancelTitle,
                    onConfirm: {
                        onConfirm()
                        isPresented.wrappedValue = false
                    },
                    onCancel: {
                        onCancel?()
                        isPresented.wrappedValue = false
                    }
                )
            }
        ))
    }
    
    /// 危险操作Alert - 带有红色危险按钮
    /// - Parameters:
    ///   - title: Alert标题
    ///   - isPresented: 控制Alert显示的绑定值
    ///   - message: Alert消息（可选）
    ///   - destructiveTitle: 危险按钮标题
    ///   - cancelTitle: 取消按钮标题
    ///   - onDestructive: 危险按钮回调
    ///   - onCancel: 取消按钮回调
    func y_destructiveAlert(
        _ title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        destructiveTitle: String = Y_AlertConstants.DefaultTitles.delete,
        cancelTitle: String = Y_AlertConstants.DefaultTitles.cancel,
        onDestructive: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        
        return self.modifier(CachedAlertModifier(
            isPresented: isPresented,
            configFactory: {
                try? Y_AlertConfig.destructive(
                    title: title,
                    message: message,
                    destructiveTitle: destructiveTitle,
                    cancelTitle: cancelTitle,
                    onDestructive: {
                        onDestructive()
                        isPresented.wrappedValue = false
                    },
                    onCancel: {
                        onCancel?()
                        isPresented.wrappedValue = false
                    }
                )
            }
        ))
    }
    
    /// TextField Alert - 单个输入框的Alert
    /// - Parameters:
    ///   - title: Alert标题
    ///   - isPresented: 控制Alert显示的绑定值
    ///   - message: Alert消息（可选）
    ///   - textFieldConfig: TextField配置
    ///   - confirmTitle: 确认按钮标题
    ///   - cancelTitle: 取消按钮标题
    ///   - onConfirm: 确认按钮回调，包含输入的文本
    ///   - onCancel: 取消按钮回调
    func y_textFieldAlert(
        _ title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        textFieldConfig: Y_TextFieldConfig,
        confirmTitle: String = Y_AlertConstants.DefaultTitles.confirm,
        cancelTitle: String = Y_AlertConstants.DefaultTitles.cancel,
        onConfirm: @escaping (String) -> Void,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        
        return self.modifier(CachedAlertModifier(
            isPresented: isPresented,
            configFactory: {
                try? Y_AlertConfig.textField(
                    title: title,
                    message: message,
                    textFieldConfig: textFieldConfig,
                    confirmTitle: confirmTitle,
                    cancelTitle: cancelTitle,
                    onConfirm: { text in
                        onConfirm(text)
                        isPresented.wrappedValue = false
                    },
                    onCancel: {
                        onCancel?()
                        isPresented.wrappedValue = false
                    }
                )
            }
        ))
    }
    
    /// 多TextField Alert
    /// - Parameters:
    ///   - title: Alert标题
    ///   - isPresented: 控制Alert显示的绑定值
    ///   - message: Alert消息（可选）
    ///   - textFieldConfigs: TextField配置数组
    ///   - confirmTitle: 确认按钮标题
    ///   - cancelTitle: 取消按钮标题
    ///   - onConfirm: 确认按钮回调，包含所有TextField的文本
    ///   - onCancel: 取消按钮回调
    func y_multiTextFieldAlert(
        _ title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        textFieldConfigs: [Y_TextFieldConfig],
        confirmTitle: String = Y_AlertConstants.DefaultTitles.confirm,
        cancelTitle: String = Y_AlertConstants.DefaultTitles.cancel,
        onConfirm: @escaping ([String]) -> Void,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        
        return self.modifier(CachedAlertModifier(
            isPresented: isPresented,
            configFactory: {
                try? Y_AlertConfig.multiTextField(
                    title: title,
                    message: message,
                    textFieldConfigs: textFieldConfigs,
                    confirmTitle: confirmTitle,
                    cancelTitle: cancelTitle,
                    onConfirm: { values in
                        onConfirm(values)
                        isPresented.wrappedValue = false
                    },
                    onCancel: {
                        onCancel?()
                        isPresented.wrappedValue = false
                    }
                )
            }
        ))
    }
}

// MARK: - ActionSheet支持
public extension View {
    
    /// ActionSheet样式的Alert
    /// - Parameters:
    ///   - title: ActionSheet标题
    ///   - isPresented: 控制显示的绑定值
    ///   - message: ActionSheet消息（可选）
    ///   - actions: 操作按钮数组
    func y_actionSheet(
        _ title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        actions: [Y_AlertAction]
    ) -> some View {
        
        return self.modifier(CachedAlertModifier(
            isPresented: isPresented,
            configFactory: {
                // 为每个action包装回调以自动关闭
                let wrappedActions = actions.map { originalAction in
                    switch originalAction.actionType {
                    case .normal(let callback):
                        return Y_AlertAction.normal(title: originalAction.title) {
                            callback()
                            isPresented.wrappedValue = false
                        }
                    case .destructive(let callback):
                        return Y_AlertAction.destructive(title: originalAction.title) {
                            callback()
                            isPresented.wrappedValue = false
                        }
                    case .cancel(let callback):
                        return Y_AlertAction.cancel(title: originalAction.title) {
                            callback()
                            isPresented.wrappedValue = false
                        }
                    case .textField(let callback):
                        // ActionSheet通常不使用TextField，但为了完整性保留
                        return Y_AlertAction.textField(title: originalAction.title) { values in
                            callback(values)
                            isPresented.wrappedValue = false
                        }
                    }
                }
                
                return try? Y_AlertConfig.actionSheet(
                    title: title,
                    message: message,
                    actions: wrappedActions
                )
            }
        ))
    }
}
