//
//  YAlertModifier.swift
//  Y_SwiftUIAlert
//
//  Created by Yue on 2025.
//

import SwiftUI

// MARK: - SwiftUI View扩展
public extension View {
    
    /// 使用YAlertManager展示Alert
    /// - Parameter config: Alert配置的绑定值，当有值时自动展示Alert
    func yAlert(_ config: Binding<YAlertConfig?>) -> some View {
        modifier(YAlertModifier(config: config))
    }
    
    /// 使用自定义AlertManager展示Alert
    /// - Parameters:
    ///   - config: Alert配置的绑定值
    ///   - manager: 自定义的AlertManager
    func yAlert(_ config: Binding<YAlertConfig?>, manager: YAlertManager) -> some View {
        modifier(YAlertModifier(config: config, manager: manager))
    }
}

// MARK: - Alert修饰符实现
public struct YAlertModifier: ViewModifier {
    @Binding var config: YAlertConfig?
    let manager: YAlertManager
    
    public init(config: Binding<YAlertConfig?>, manager: YAlertManager = .shared) {
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
    
    private func presentAlert(_ alertConfig: YAlertConfig) {
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
    let configFactory: () -> YAlertConfig?
    let manager: YAlertManager
    
    @State private var cachedConfig: YAlertConfig?
    
    public init(
        isPresented: Binding<Bool>,
        configFactory: @escaping () -> YAlertConfig?,
        manager: YAlertManager = .shared
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
    
    private func presentAlert(_ alertConfig: YAlertConfig) {
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
    func ySimpleAlert(
        _ title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        confirmTitle: String = YAlertConstants.DefaultTitles.confirm,
        onConfirm: (() -> Void)? = nil
    ) -> some View {
        
        return self.modifier(CachedAlertModifier(
            isPresented: isPresented,
            configFactory: {
                try? YAlertConfig.simple(
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
    func yConfirmAlert(
        _ title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        confirmTitle: String = YAlertConstants.DefaultTitles.confirm,
        cancelTitle: String = YAlertConstants.DefaultTitles.cancel,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        
        return self.modifier(CachedAlertModifier(
            isPresented: isPresented,
            configFactory: {
                try? YAlertConfig.confirm(
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
    func yDestructiveAlert(
        _ title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        destructiveTitle: String = YAlertConstants.DefaultTitles.delete,
        cancelTitle: String = YAlertConstants.DefaultTitles.cancel,
        onDestructive: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        
        return self.modifier(CachedAlertModifier(
            isPresented: isPresented,
            configFactory: {
                try? YAlertConfig.destructive(
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
    func yTextFieldAlert(
        _ title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        textFieldConfig: YTextFieldConfig,
        confirmTitle: String = YAlertConstants.DefaultTitles.confirm,
        cancelTitle: String = YAlertConstants.DefaultTitles.cancel,
        onConfirm: @escaping (String) -> Void,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        
        return self.modifier(CachedAlertModifier(
            isPresented: isPresented,
            configFactory: {
                try? YAlertConfig.textField(
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
    func yMultiTextFieldAlert(
        _ title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        textFieldConfigs: [YTextFieldConfig],
        confirmTitle: String = YAlertConstants.DefaultTitles.confirm,
        cancelTitle: String = YAlertConstants.DefaultTitles.cancel,
        onConfirm: @escaping ([String]) -> Void,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        
        return self.modifier(CachedAlertModifier(
            isPresented: isPresented,
            configFactory: {
                try? YAlertConfig.multiTextField(
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
    func yActionSheet(
        _ title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        actions: [YAlertAction]
    ) -> some View {
        
        return self.modifier(CachedAlertModifier(
            isPresented: isPresented,
            configFactory: {
                // 为每个action包装回调以自动关闭
                let wrappedActions = actions.map { originalAction in
                    switch originalAction.actionType {
                    case .normal(let callback):
                        return YAlertAction.normal(title: originalAction.title) {
                            callback()
                            isPresented.wrappedValue = false
                        }
                    case .destructive(let callback):
                        return YAlertAction.destructive(title: originalAction.title) {
                            callback()
                            isPresented.wrappedValue = false
                        }
                    case .cancel(let callback):
                        return YAlertAction.cancel(title: originalAction.title) {
                            callback()
                            isPresented.wrappedValue = false
                        }
                    case .textField(let callback):
                        // ActionSheet通常不使用TextField，但为了完整性保留
                        return YAlertAction.textField(title: originalAction.title) { values in
                            callback(values)
                            isPresented.wrappedValue = false
                        }
                    }
                }
                
                return try? YAlertConfig.actionSheet(
                    title: title,
                    message: message,
                    actions: wrappedActions
                )
            }
        ))
    }
}
