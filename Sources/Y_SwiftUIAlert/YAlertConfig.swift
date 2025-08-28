//
//  YAlertConfig.swift
//  Y_SwiftUIAlert
//
//  Created by Yue on 2025.
//

import UIKit

// MARK: - Alert样式
public enum YAlertStyle {
    case alert          // 标准Alert样式
    case actionSheet    // ActionSheet样式
    
    internal var uiAlertStyle: UIAlertController.Style {
        switch self {
        case .alert:
            return .alert
        case .actionSheet:
            return .actionSheet
        }
    }
}

// MARK: - Alert错误类型
public enum YAlertError: LocalizedError {
    case noValidWindow
    case configurationInvalid(reason: String)
    case presentationFailed(underlying: Error)
    case tooManyTextFields(count: Int, max: Int)
    case tooManyActions(count: Int, max: Int)
    
    public var errorDescription: String? {
        switch self {
        case .noValidWindow:
            return "无法找到有效的窗口来展示Alert"
        case .configurationInvalid(let reason):
            return "Alert配置无效: \(reason)"
        case .presentationFailed(let error):
            return "Alert展示失败: \(error.localizedDescription)"
        case .tooManyTextFields(let count, let max):
            return "TextField数量超限: \(count) > \(max)"
        case .tooManyActions(let count, let max):
            return "Action数量超限: \(count) > \(max)"
        }
    }
}

// MARK: - Alert统一配置模型
public struct YAlertConfig: Equatable {
    public let id = UUID()
    public let title: String
    public let message: String?
    public let textFields: [YTextFieldConfig]
    public let actions: [YAlertAction]
    public let style: YAlertStyle
    public let preferredActionIndex: Int? // 首选按钮索引
    
    // MARK: - 初始化方法
    public init(
        title: String,
        message: String? = nil,
        textFields: [YTextFieldConfig] = [],
        actions: [YAlertAction],
        style: YAlertStyle = .alert,
        preferredActionIndex: Int? = nil
    ) throws {
        // 验证配置有效性
        guard !actions.isEmpty else {
            throw YAlertError.configurationInvalid(reason: "至少需要一个Action")
        }
        
        guard textFields.count <= YAlertConstants.maxTextFieldCount else {
            throw YAlertError.tooManyTextFields(count: textFields.count, max: YAlertConstants.maxTextFieldCount)
        }
        
        guard actions.count <= YAlertConstants.maxActionCount else {
            throw YAlertError.tooManyActions(count: actions.count, max: YAlertConstants.maxActionCount)
        }
        
        if let preferredIndex = preferredActionIndex {
            guard preferredIndex >= 0 && preferredIndex < actions.count else {
                throw YAlertError.configurationInvalid(reason: "首选Action索引超出范围")
            }
        }
        
        self.title = title
        self.message = message
        self.textFields = textFields
        self.actions = actions
        self.style = style
        self.preferredActionIndex = preferredActionIndex
        
        debugLog("创建YAlertConfig: '\(title)' - \(textFields.count)个TextField, \(actions.count)个Action")
    }
    
    // MARK: - Equatable实现
    public static func == (lhs: YAlertConfig, rhs: YAlertConfig) -> Bool {
        // 基于id进行比较，因为包含闭包无法直接比较其他属性
        return lhs.id == rhs.id
    }
}

// MARK: - 便利构造方法
public extension YAlertConfig {
    
    /// 简单Alert - 只有消息和确认按钮
    static func simple(
        title: String,
        message: String? = nil,
        confirmTitle: String = YAlertConstants.DefaultTitles.confirm,
        onConfirm: (() -> Void)? = nil
    ) throws -> YAlertConfig {
        let confirmAction = onConfirm != nil ? 
            YAlertAction.normal(title: confirmTitle, action: onConfirm!) : 
            YAlertAction.normal(title: confirmTitle, action: {})
            
        return try YAlertConfig(
            title: title,
            message: message,
            actions: [confirmAction]
        )
    }
    
    /// 确认Alert - 确认和取消按钮
    static func confirm(
        title: String,
        message: String? = nil,
        confirmTitle: String = YAlertConstants.DefaultTitles.confirm,
        cancelTitle: String = YAlertConstants.DefaultTitles.cancel,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) throws -> YAlertConfig {
        let actions = [
            YAlertAction.cancel(title: cancelTitle, action: onCancel ?? {}),
            YAlertAction.normal(title: confirmTitle, action: onConfirm)
        ]
        
        return try YAlertConfig(
            title: title,
            message: message,
            actions: actions,
            preferredActionIndex: 1 // 确认按钮为首选
        )
    }
    
    /// 危险操作Alert - 带有红色危险按钮
    static func destructive(
        title: String,
        message: String? = nil,
        destructiveTitle: String = YAlertConstants.DefaultTitles.delete,
        cancelTitle: String = YAlertConstants.DefaultTitles.cancel,
        onDestructive: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) throws -> YAlertConfig {
        let actions = [
            YAlertAction.cancel(title: cancelTitle, action: onCancel ?? {}),
            YAlertAction.destructive(title: destructiveTitle, action: onDestructive)
        ]
        
        return try YAlertConfig(
            title: title,
            message: message,
            actions: actions,
            preferredActionIndex: 1 // 危险按钮为首选
        )
    }
    
    /// 单TextField Alert
    static func textField(
        title: String,
        message: String? = nil,
        textFieldConfig: YTextFieldConfig,
        confirmTitle: String = YAlertConstants.DefaultTitles.confirm,
        cancelTitle: String = YAlertConstants.DefaultTitles.cancel,
        onConfirm: @escaping (String) -> Void,
        onCancel: (() -> Void)? = nil
    ) throws -> YAlertConfig {
        let actions = [
            YAlertAction.cancel(title: cancelTitle, action: onCancel ?? {}),
            YAlertAction.confirm(singleTextFieldAction: onConfirm)
        ]
        
        return try YAlertConfig(
            title: title,
            message: message,
            textFields: [textFieldConfig],
            actions: actions,
            preferredActionIndex: 1
        )
    }
    
    /// 多TextField Alert
    static func multiTextField(
        title: String,
        message: String? = nil,
        textFieldConfigs: [YTextFieldConfig],
        confirmTitle: String = YAlertConstants.DefaultTitles.confirm,
        cancelTitle: String = YAlertConstants.DefaultTitles.cancel,
        onConfirm: @escaping ([String]) -> Void,
        onCancel: (() -> Void)? = nil
    ) throws -> YAlertConfig {
        let actions = [
            YAlertAction.cancel(title: cancelTitle, action: onCancel ?? {}),
            YAlertAction.confirm(textFieldAction: onConfirm)
        ]
        
        return try YAlertConfig(
            title: title,
            message: message,
            textFields: textFieldConfigs,
            actions: actions,
            preferredActionIndex: 1
        )
    }
    
    /// ActionSheet
    static func actionSheet(
        title: String,
        message: String? = nil,
        actions: [YAlertAction]
    ) throws -> YAlertConfig {
        return try YAlertConfig(
            title: title,
            message: message,
            actions: actions,
            style: .actionSheet
        )
    }
}

// MARK: - Builder模式支持
public class YAlertBuilder {
    private var title: String
    private var message: String?
    private var textFields: [YTextFieldConfig] = []
    private var actions: [YAlertAction] = []
    private var style: YAlertStyle = .alert
    private var preferredActionIndex: Int?
    
    public init(title: String) {
        self.title = title
    }
    
    public func message(_ message: String) -> Self {
        self.message = message
        return self
    }
    
    public func textField(_ config: YTextFieldConfig) -> Self {
        textFields.append(config)
        return self
    }
    
    public func textField(_ builder: (YTextFieldBuilder) -> YTextFieldBuilder) -> Self {
        let textFieldBuilder = YTextFieldBuilder(placeholder: "")
        let config = builder(textFieldBuilder).build()
        textFields.append(config)
        return self
    }
    
    public func action(_ action: YAlertAction) -> Self {
        actions.append(action)
        return self
    }
    
    public func confirmButton(
        title: String = YAlertConstants.DefaultTitles.confirm,
        action: @escaping () -> Void
    ) -> Self {
        let confirmAction = YAlertAction.normal(title: title, action: action)
        actions.append(confirmAction)
        if preferredActionIndex == nil {
            preferredActionIndex = actions.count - 1
        }
        return self
    }
    
    public func confirmButton(
        title: String = YAlertConstants.DefaultTitles.confirm,
        textFieldAction: @escaping ([String]) -> Void
    ) -> Self {
        let confirmAction = YAlertAction.textField(title: title, action: textFieldAction)
        actions.append(confirmAction)
        if preferredActionIndex == nil {
            preferredActionIndex = actions.count - 1
        }
        return self
    }
    
    public func cancelButton(
        title: String = YAlertConstants.DefaultTitles.cancel,
        action: (() -> Void)? = nil
    ) -> Self {
        let cancelAction = YAlertAction.cancel(title: title, action: action ?? {})
        actions.append(cancelAction)
        return self
    }
    
    public func deleteButton(action: @escaping () -> Void) -> Self {
        let deleteAction = YAlertAction.delete(action: action)
        actions.append(deleteAction)
        return self
    }
    
    public func style(_ style: YAlertStyle) -> Self {
        self.style = style
        return self
    }
    
    public func preferredAction(at index: Int) -> Self {
        preferredActionIndex = index
        return self
    }
    
    public func build() throws -> YAlertConfig {
        return try YAlertConfig(
            title: title,
            message: message,
            textFields: textFields,
            actions: actions,
            style: style,
            preferredActionIndex: preferredActionIndex
        )
    }
}
