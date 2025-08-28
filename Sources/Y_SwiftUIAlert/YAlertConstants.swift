//
//  YAlertConstants.swift
//  Y_SwiftUIAlert
//
//  Created by Yue on 2025.
//

import Foundation

// MARK: - 配置常量
public struct YAlertConstants {
    
    // MARK: - 动画配置
    public static let defaultAnimationDuration: TimeInterval = 0.3
    public static let validationDebounceTime: TimeInterval = 0.3
    
    // MARK: - 限制配置
    public static let maxTextFieldCount = 5
    public static let maxActionCount = 8
    public static let defaultValidationDelay: TimeInterval = 0.2
    
    // MARK: - 默认标题
    public struct DefaultTitles {
        public static let confirm = "确定"
        public static let cancel = "取消" 
        public static let delete = "删除"
        public static let ok = "好的"
        public static let retry = "重试"
        public static let save = "保存"
    }
    
    // MARK: - 默认消息
    public struct DefaultMessages {
        public static let loading = "请稍候..."
        public static let networkError = "网络连接异常，请检查网络设置"
        public static let unknownError = "操作失败，请重试"
        public static let confirmDelete = "此操作不可撤销，确定要删除吗？"
    }
    
    // MARK: - 验证错误消息
    public struct ValidationMessages {
        public static let required = "此字段为必填项"
        public static let tooShort = "输入内容太短"
        public static let tooLong = "输入内容太长"
        public static let invalidFormat = "格式不正确"
        public static let emailInvalid = "邮箱格式不正确"
        public static let phoneInvalid = "手机号格式不正确"
        
        public static func lengthRange(min: Int, max: Int) -> String {
            return "请输入\(min)-\(max)个字符"
        }
        
        public static func minLength(_ min: Int) -> String {
            return "最少需要\(min)个字符"
        }
        
        public static func maxLength(_ max: Int) -> String {
            return "最多允许\(max)个字符"
        }
    }
}

// MARK: - 国际化支持
public struct YAlertLocalizable {
    public static let confirm = NSLocalizedString("yalert.confirm", 
                                                  value: "确定", 
                                                  comment: "确认按钮")
    public static let cancel = NSLocalizedString("yalert.cancel", 
                                                 value: "取消", 
                                                 comment: "取消按钮")
    public static let delete = NSLocalizedString("yalert.delete", 
                                                 value: "删除", 
                                                 comment: "删除按钮")
    public static let ok = NSLocalizedString("yalert.ok", 
                                             value: "好的", 
                                             comment: "确认按钮")
    public static let retry = NSLocalizedString("yalert.retry", 
                                                value: "重试", 
                                                comment: "重试按钮")
    public static let save = NSLocalizedString("yalert.save", 
                                               value: "保存", 
                                               comment: "保存按钮")
    
    // MARK: - 验证错误本地化
    public static let validationRequired = NSLocalizedString("yalert.validation.required", 
                                                            value: "此字段为必填项", 
                                                            comment: "必填验证错误")
    
    public static func validationLength(min: Int, max: Int) -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString("yalert.validation.length", 
                            value: "请输入%d-%d个字符", 
                            comment: "长度验证错误"), 
            min, max
        )
    }
    
    public static func validationMinLength(_ min: Int) -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString("yalert.validation.minLength", 
                            value: "最少需要%d个字符", 
                            comment: "最小长度验证错误"), 
            min
        )
    }
    
    public static func validationMaxLength(_ max: Int) -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString("yalert.validation.maxLength", 
                            value: "最多允许%d个字符", 
                            comment: "最大长度验证错误"), 
            max
        )
    }
}