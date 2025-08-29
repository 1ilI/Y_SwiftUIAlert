//
//  YAlertValidation.swift
//  Y_SwiftUIAlert
//
//  Created by Yue on 2025.
//

import Foundation

// MARK: - 验证结果
public enum YValidationResult: Equatable {
    case valid
    case invalid(message: String)
    case warning(message: String)
    
    public var isValid: Bool {
        if case .valid = self {
            return true
        }
        return false
    }
    
    public var errorMessage: String? {
        switch self {
        case .invalid(let message):
            return message
        case .warning(let message):
            return message
        case .valid:
            return nil
        }
    }
}

// MARK: - 验证规则
public struct YValidationRule {
    public let validator: (String) -> YValidationResult
    public let priority: Int // 优先级，数字越小优先级越高
    
    private init(priority: Int = 0, validator: @escaping (String) -> YValidationResult) {
        self.priority = priority
        self.validator = validator
    }
    
    // MARK: - 预定义验证规则
    
    /// 必填验证
    public static var required: YValidationRule {
        return YValidationRule(priority: 0) { text in
            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return .invalid(message: Y_AlertLocalizable.validationRequired)
            }
            return .valid
        }
    }
    
    /// 长度范围验证
    public static func length(min: Int, max: Int) -> YValidationRule {
        return YValidationRule(priority: 1) { text in
            let count = text.count
            guard count >= min else {
                return .invalid(message: Y_AlertLocalizable.validationMinLength(min))
            }
            guard count <= max else {
                return .invalid(message: Y_AlertLocalizable.validationMaxLength(max))
            }
            return .valid
        }
    }
    
    /// 最小长度验证
    public static func minLength(_ min: Int) -> YValidationRule {
        return YValidationRule(priority: 1) { text in
            guard text.count >= min else {
                return .invalid(message: Y_AlertLocalizable.validationMinLength(min))
            }
            return .valid
        }
    }
    
    /// 最大长度验证
    public static func maxLength(_ max: Int) -> YValidationRule {
        return YValidationRule(priority: 1) { text in
            guard text.count <= max else {
                return .invalid(message: Y_AlertLocalizable.validationMaxLength(max))
            }
            return .valid
        }
    }
    
    /// 正则表达式验证
    public static func regex(_ pattern: String, message: String) -> YValidationRule {
        return YValidationRule(priority: 2) { text in
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                return .invalid(message: "验证规则配置错误")
            }
            
            let range = NSRange(location: 0, length: text.utf16.count)
            let matches = regex.matches(in: text, options: [], range: range)
            
            guard !matches.isEmpty else {
                return .invalid(message: message)
            }
            return .valid
        }
    }
    
    /// 邮箱格式验证
    public static var email: YValidationRule {
        let emailPattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return regex(emailPattern, message: "邮箱格式不正确")
    }
    
    /// 手机号格式验证（中国大陆）
    public static var phone: YValidationRule {
        let phonePattern = "^1[3-9]\\d{9}$"
        return regex(phonePattern, message: "手机号格式不正确")
    }
    
    /// 数字验证
    public static var numeric: YValidationRule {
        return YValidationRule(priority: 2) { text in
            guard Double(text) != nil else {
                return .invalid(message: "请输入有效的数字")
            }
            return .valid
        }
    }
    
    /// 数字范围验证
    public static func numericRange(min: Double, max: Double) -> YValidationRule {
        return YValidationRule(priority: 2) { text in
            guard let number = Double(text) else {
                return .invalid(message: "请输入有效的数字")
            }
            guard number >= min && number <= max else {
                return .invalid(message: "请输入\(min)-\(max)之间的数字")
            }
            return .valid
        }
    }
    
    /// 自定义验证规则
    public static func custom(priority: Int = 3, validator: @escaping (String) -> YValidationResult) -> YValidationRule {
        return YValidationRule(priority: priority, validator: validator)
    }
    
    /// 自定义验证规则（简化版本，只返回是否有效）
    public static func custom(priority: Int = 3, message: String, validator: @escaping (String) -> Bool) -> YValidationRule {
        return YValidationRule(priority: priority) { text in
            return validator(text) ? .valid : .invalid(message: message)
        }
    }
}

// MARK: - 验证规则组合
public struct Y_ValidationRuleSet {
    private let rules: [YValidationRule]
    
    public init(_ rules: [YValidationRule]) {
        // 按优先级排序
        self.rules = rules.sorted { $0.priority < $1.priority }
    }
    
    public init(_ rules: YValidationRule...) {
        self.init(rules)
    }
    
    /// 验证文本，返回第一个失败的验证结果
    public func validate(_ text: String) -> YValidationResult {
        for rule in rules {
            let result = rule.validator(text)
            if !result.isValid {
                return result
            }
        }
        return .valid
    }
    
    /// 验证文本，返回所有验证结果
    public func validateAll(_ text: String) -> [YValidationResult] {
        return rules.map { $0.validator(text) }
    }
}
