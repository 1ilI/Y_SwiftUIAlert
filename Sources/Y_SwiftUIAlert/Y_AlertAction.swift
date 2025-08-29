//
//  Y_AlertAction.swift
//  Y_SwiftUIAlert
//
//  Created by Yue on 2025.
//

import UIKit

// MARK: - Alert动作类型
public enum Y_AlertActionType {
    case normal(() -> Void)
    case textField(([String]) -> Void)
    case destructive(() -> Void)
    case cancel(() -> Void)
}

// MARK: - Alert动作
public struct Y_AlertAction {
    public let title: String
    public let style: UIAlertAction.Style
    internal let actionType: Y_AlertActionType
    
    // MARK: - 私有初始化方法
    private init(title: String, style: UIAlertAction.Style, actionType: Y_AlertActionType) {
        self.title = title
        self.style = style
        self.actionType = actionType
        
        let actionTypeName = switch actionType {
        case .normal: "普通"
        case .textField: "TextField"
        case .destructive: "危险"
        case .cancel: "取消"
        }
        
    }
    
    // MARK: - 静态工厂方法
    
    /// 普通动作
    public static func normal(
        title: String = Y_AlertConstants.DefaultTitles.confirm,
        action: @escaping () -> Void
    ) -> Y_AlertAction {
        return Y_AlertAction(
            title: title,
            style: .default,
            actionType: .normal(action)
        )
    }
    
    /// TextField相关动作
    public static func textField(
        title: String = Y_AlertConstants.DefaultTitles.confirm,
        action: @escaping ([String]) -> Void
    ) -> Y_AlertAction {
        return Y_AlertAction(
            title: title,
            style: .default,
            actionType: .textField(action)
        )
    }
    
    /// 危险动作
    public static func destructive(
        title: String = Y_AlertConstants.DefaultTitles.delete,
        action: @escaping () -> Void
    ) -> Y_AlertAction {
        return Y_AlertAction(
            title: title,
            style: .destructive,
            actionType: .destructive(action)
        )
    }
    
    /// 取消动作
    public static func cancel(
        title: String = Y_AlertConstants.DefaultTitles.cancel,
        action: (() -> Void)? = nil
    ) -> Y_AlertAction {
        return Y_AlertAction(
            title: title,
            style: .cancel,
            actionType: .cancel(action ?? {})
        )
    }
    
    // MARK: - 便利构造方法
    
    /// 确认动作（普通）
    public static func confirm(action: @escaping () -> Void) -> Y_AlertAction {
        return .normal(title: Y_AlertLocalizable.confirm, action: action)
    }
    
    /// 确认动作（TextField）
    public static func confirm(textFieldAction: @escaping ([String]) -> Void) -> Y_AlertAction {
        return .textField(title: Y_AlertLocalizable.confirm, action: textFieldAction)
    }
    
    /// 单TextField确认动作
    public static func confirm(singleTextFieldAction: @escaping (String) -> Void) -> Y_AlertAction {
        return .textField(title: Y_AlertLocalizable.confirm) { values in
            singleTextFieldAction(values.first ?? "")
        }
    }
    
    /// 取消动作（无回调）
    public static var cancel: Y_AlertAction {
        return .cancel()
    }
    
    /// 取消动作（有回调）
    public static func cancel(action: @escaping () -> Void) -> Y_AlertAction {
        return .cancel(title: Y_AlertLocalizable.cancel, action: action)
    }
    
    /// 删除动作
    public static func delete(action: @escaping () -> Void) -> Y_AlertAction {
        return .destructive(title: Y_AlertLocalizable.delete, action: action)
    }
    
    /// 保存动作
    public static func save(action: @escaping () -> Void) -> Y_AlertAction {
        return .normal(title: Y_AlertLocalizable.save, action: action)
    }
    
    /// 重试动作
    public static func retry(action: @escaping () -> Void) -> Y_AlertAction {
        return .normal(title: Y_AlertLocalizable.retry, action: action)
    }
    
    // MARK: - 内部执行方法
    internal func execute(with textFieldValues: [String] = []) {
        debugLog("执行动作: '\(title)'")
        
        switch actionType {
        case .normal(let callback):
            callback()
        case .textField(let callback):
            debugLog("传递TextField值: \(textFieldValues)")
            callback(textFieldValues)
        case .destructive(let callback):
            callback()
        case .cancel(let callback):
            callback()
        }
    }
}
