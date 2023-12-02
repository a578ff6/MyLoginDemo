//
//  Utilities.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/29.
//

import UIKit

/// Utilities: 提供統一樣式設定，包括文字輸入框、按鈕、圖片視圖和標籤。
class Utilities {
    
    /// TextField設定底部線條樣式
    static func styleTextField(_ textField: UITextField) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width - 40, height: 2)
        bottomLine.backgroundColor = UIColor.init(red: 0, green: 153/255, blue: 153/255, alpha: 1).cgColor
        
        textField.borderStyle = .none
        textField.layer.addSublayer(bottomLine)
    }
    
    /// Button設定填充背景樣式
    static func styleFilledButton(_ button: UIButton) {
        button.backgroundColor = UIColor(red: 0, green: 153/255, blue: 153/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    /// Button設定邊框樣式
    static func styleHollowButton(_ button: UIButton) {
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor(red: 0, green: 153/255, blue: 153/255, alpha: 1).cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.label
    }
    
    /// ImageView設定圓形樣式
    static func styleImageView(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.clipsToBounds = true
    }
    
    /// Label添加底部線條樣式
    static func styleLabelWithUnderLine(_ label: UILabel) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: label.frame.height - 2, width: label.frame.width - 40, height: 2)
        bottomLine.backgroundColor = UIColor.init(red: 0, green: 153/255, blue: 153/255, alpha: 1).cgColor
        
        label.layer.addSublayer(bottomLine)
    }
    
}
