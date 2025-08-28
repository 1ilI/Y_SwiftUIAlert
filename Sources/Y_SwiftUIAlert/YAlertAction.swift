//
//  YAlertAction.swift
//  Y_SwiftUIAlert
//
//  Created by Yue on 2025.
//

import UIKit

// MARK: - Alert动作类型
public enum YAlertActionType {
    case normal(() -> Void)
    case textField(([String]) -> Void)
    case destructive(() -> Void)
    case cancel(() -> Void)
}

// MARK: - Alert动作
public struct YAlertAction {
    public let title: String
    public let style: UIAlertAction.Style
    internal let actionType: YAlertActionType
    
    // MARK: - 私有初始化方法
    private init(title: String, style: UIAlertAction.Style, actionType: YAlertActionType) {
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
        title: String = YAlertConstants.DefaultTitles.confirm,
        action: @escaping () -> Void
    ) -> YAlertAction {
        return YAlertAction(
            title: title,
            style: .default,
            actionType: .normal(action)
        )
    }
    
    /// TextField相关动作
    public static func textField(
        title: String = YAlertConstants.DefaultTitles.confirm,
        action: @escaping ([String]) -> Void
    ) -> YAlertAction {
        return YAlertAction(
            title: title,
            style: .default,
            actionType: .textField(action)
        )
    }
    
    /// 危险动作
    public static func destructive(
        title: String = YAlertConstants.DefaultTitles.delete,
        action: @escaping () -> Void
    ) -> YAlertAction {
        return YAlertAction(
            title: title,
            style: .destructive,
            actionType: .destructive(action)
        )
    }
    
    /// 取消动作
    public static func cancel(
        title: String = YAlertConstants.DefaultTitles.cancel,
        action: (() -> Void)? = nil
    ) -> YAlertAction {
        return YAlertAction(
            title: title,
            style: .cancel,
            actionType: .cancel(action ?? {})
        )
    }
    
    // MARK: - 便利构造方法
    
    /// 确认动作（普通）
    public static func confirm(action: @escaping () -> Void) -> YAlertAction {
        return .normal(title: YAlertLocalizable.confirm, action: action)
    }
    
    /// 确认动作（TextField）
    public static func confirm(textFieldAction: @escaping ([String]) -> Void) -> YAlertAction {
        return .textField(title: YAlertLocalizable.confirm, action: textFieldAction)
    }
    
    /// 单TextField确认动作
    public static func confirm(singleTextFieldAction: @escaping (String) -> Void) -> YAlertAction {
        return .textField(title: YAlertLocalizable.confirm) { values in
            singleTextFieldAction(values.first ?? "")
        }
    }
    
    /// 取消动作（无回调）
    public static var cancel: YAlertAction {
        return .cancel()
    }
    
    /// 取消动作（有回调）
    public static func cancel(action: @escaping () -> Void) -> YAlertAction {
        return .cancel(title: YAlertLocalizable.cancel, action: action)
    }
    
    /// 删除动作
    public static func delete(action: @escaping () -> Void) -> YAlertAction {
        return .destructive(title: YAlertLocalizable.delete, action: action)
    }
    
    /// 保存动作
    public static func save(action: @escaping () -> Void) -> YAlertAction {
        return .normal(title: YAlertLocalizable.save, action: action)
    }
    
    /// 重试动作
    public static func retry(action: @escaping () -> Void) -> YAlertAction {
        return .normal(title: YAlertLocalizable.retry, action: action)
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
