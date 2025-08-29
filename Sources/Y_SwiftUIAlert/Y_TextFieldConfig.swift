//
//  Y_TextFieldConfig.swift
//  Y_SwiftUIAlert
//
//  Created by Yue on 2025.
//

import UIKit

// MARK: - TextField配置模型
public struct Y_TextFieldConfig {
    
    // MARK: - 基础配置
    public let placeholder: String
    public let initialText: String
    public let keyboardType: UIKeyboardType
    public let isSecure: Bool
    public let autocapitalizationType: UITextAutocapitalizationType
    public let autocorrectionType: UITextAutocorrectionType
    
    // MARK: - 验证配置
    public let validationRules: Y_ValidationRuleSet?
    public let validateOnChange: Bool // 是否实时验证
    public let showInlineError: Bool  // 是否在TextField下方显示错误
    
    // MARK: - 外观配置
    public let textColor: UIColor?
    public let font: UIFont?
    public let backgroundColor: UIColor?
    public let borderStyle: UITextField.BorderStyle?
    public let clearButtonMode: UITextField.ViewMode
    public let returnKeyType: UIReturnKeyType
    
    // MARK: - 高级配置
    public let customConfiguration: ((UITextField) -> Void)?
    public let maxLength: Int?
    public let allowedCharacters: CharacterSet?
    
    // MARK: - 回调事件
    public let onTextChanged: ((String) -> Void)?
    public let onEditingBegan: (() -> Void)?
    public let onEditingEnded: (() -> Void)?
    public let onReturnPressed: (() -> Void)?
    
    // MARK: - 初始化方法
    public init(
        placeholder: String,
        initialText: String = "",
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        autocapitalizationType: UITextAutocapitalizationType = .sentences,
        autocorrectionType: UITextAutocorrectionType = .default,
        validationRules: Y_ValidationRuleSet? = nil,
        validateOnChange: Bool = true,
        showInlineError: Bool = false,
        textColor: UIColor? = nil,
        font: UIFont? = nil,
        backgroundColor: UIColor? = nil,
        borderStyle: UITextField.BorderStyle? = nil,
        clearButtonMode: UITextField.ViewMode = .whileEditing,
        returnKeyType: UIReturnKeyType = .default,
        customConfiguration: ((UITextField) -> Void)? = nil,
        maxLength: Int? = nil,
        allowedCharacters: CharacterSet? = nil,
        onTextChanged: ((String) -> Void)? = nil,
        onEditingBegan: (() -> Void)? = nil,
        onEditingEnded: (() -> Void)? = nil,
        onReturnPressed: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self.initialText = initialText
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.autocapitalizationType = autocapitalizationType
        self.autocorrectionType = autocorrectionType
        self.validationRules = validationRules
        self.validateOnChange = validateOnChange
        self.showInlineError = showInlineError
        self.textColor = textColor
        self.font = font
        self.backgroundColor = backgroundColor
        self.borderStyle = borderStyle
        self.clearButtonMode = clearButtonMode
        self.returnKeyType = returnKeyType
        self.customConfiguration = customConfiguration
        self.maxLength = maxLength
        self.allowedCharacters = allowedCharacters
        self.onTextChanged = onTextChanged
        self.onEditingBegan = onEditingBegan
        self.onEditingEnded = onEditingEnded
        self.onReturnPressed = onReturnPressed
    }
}

// MARK: - 便利构造方法
public extension Y_TextFieldConfig {
    
    /// 普通文本输入
    static func text(
        placeholder: String,
        initialText: String = "",
        validation: Y_ValidationRuleSet? = nil
    ) -> Y_TextFieldConfig {
        return Y_TextFieldConfig(
            placeholder: placeholder,
            initialText: initialText,
            keyboardType: .default,
            validationRules: validation
        )
    }
    
    /// 密码输入
    static func password(
        placeholder: String = "请输入密码",
        validation: Y_ValidationRuleSet? = nil
    ) -> Y_TextFieldConfig {
        return Y_TextFieldConfig(
            placeholder: placeholder,
            keyboardType: .default,
            isSecure: true,
            autocapitalizationType: .none,
            autocorrectionType: .no,
            validationRules: validation,
            clearButtonMode: .whileEditing
        )
    }
    
    /// 邮箱输入
    static func email(
        placeholder: String = "请输入邮箱地址",
        validation: Y_ValidationRuleSet? = nil
    ) -> Y_TextFieldConfig {
        let emailValidation = validation ?? Y_ValidationRuleSet(.email)
        return Y_TextFieldConfig(
            placeholder: placeholder,
            keyboardType: .emailAddress,
            autocapitalizationType: .none,
            autocorrectionType: .no,
            validationRules: emailValidation
        )
    }
    
    /// 手机号输入
    static func phone(
        placeholder: String = "请输入手机号",
        validation: Y_ValidationRuleSet? = nil
    ) -> Y_TextFieldConfig {
        let phoneValidation = validation ?? Y_ValidationRuleSet(.phone)
        return Y_TextFieldConfig(
            placeholder: placeholder,
            keyboardType: .phonePad,
            validationRules: phoneValidation,
            maxLength: 11,
            allowedCharacters: CharacterSet.decimalDigits
        )
    }
    
    /// 数字输入
    static func number(
        placeholder: String = "请输入数字",
        validation: Y_ValidationRuleSet? = nil,
        allowDecimal: Bool = true
    ) -> Y_TextFieldConfig {
        let numberValidation = validation ?? Y_ValidationRuleSet(.numeric)
        let keyboardType: UIKeyboardType = allowDecimal ? .decimalPad : .numberPad
        let allowedChars: CharacterSet = allowDecimal ? 
            CharacterSet(charactersIn: "0123456789.") : 
            CharacterSet.decimalDigits
            
        return Y_TextFieldConfig(
            placeholder: placeholder,
            keyboardType: keyboardType,
            validationRules: numberValidation,
            allowedCharacters: allowedChars
        )
    }
    
    /// 用户名输入
    static func username(
        placeholder: String = "请输入用户名",
        minLength: Int = 3,
        maxLength: Int = 20
    ) -> Y_TextFieldConfig {
        let validation = Y_ValidationRuleSet([
            .required,
            .length(min: minLength, max: maxLength)
        ])
        
        return Y_TextFieldConfig(
            placeholder: placeholder,
            keyboardType: .default,
            autocapitalizationType: .none,
            autocorrectionType: .no,
            validationRules: validation,
            maxLength: maxLength
        )
    }
    
    /// 昵称输入
    static func nickname(
        placeholder: String = "请输入昵称",
        minLength: Int = 2,
        maxLength: Int = 15
    ) -> Y_TextFieldConfig {
        let validation = Y_ValidationRuleSet([
            .required,
            .length(min: minLength, max: maxLength)
        ])
        
        return Y_TextFieldConfig(
            placeholder: placeholder,
            validationRules: validation,
            maxLength: maxLength
        )
    }
}

// MARK: - Builder模式支持
public class YTextFieldBuilder {
    private var config: Y_TextFieldConfig
    
    public init(placeholder: String) {
        self.config = Y_TextFieldConfig(placeholder: placeholder)
    }
    
    public func initialText(_ text: String) -> Self {
        config = Y_TextFieldConfig(
            placeholder: config.placeholder,
            initialText: text,
            keyboardType: config.keyboardType,
            isSecure: config.isSecure,
            autocapitalizationType: config.autocapitalizationType,
            autocorrectionType: config.autocorrectionType,
            validationRules: config.validationRules,
            validateOnChange: config.validateOnChange,
            showInlineError: config.showInlineError,
            textColor: config.textColor,
            font: config.font,
            backgroundColor: config.backgroundColor,
            borderStyle: config.borderStyle,
            clearButtonMode: config.clearButtonMode,
            returnKeyType: config.returnKeyType,
            customConfiguration: config.customConfiguration,
            maxLength: config.maxLength,
            allowedCharacters: config.allowedCharacters,
            onTextChanged: config.onTextChanged,
            onEditingBegan: config.onEditingBegan,
            onEditingEnded: config.onEditingEnded,
            onReturnPressed: config.onReturnPressed
        )
        return self
    }
    
    public func keyboardType(_ type: UIKeyboardType) -> Self {
        // 类似的Builder方法实现...
        return self
    }
    
    public func validation(_ rules: Y_ValidationRuleSet) -> Self {
        // Builder方法实现...
        return self
    }
    
    public func isSecure(_ secure: Bool = true) -> Self {
        // Builder方法实现...
        return self
    }
    
    public func build() -> Y_TextFieldConfig {
        return config
    }
}
