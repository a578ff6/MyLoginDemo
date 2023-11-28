//
//  Utilities.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/29.
//

import Foundation
import UIKit


class Utilities {
    
    static func styleTextField(_ textField: UITextField) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)
        bottomLine.backgroundColor = UIColor.init(red: 0, green: 153/255, blue: 153/255, alpha: 1).cgColor
        
        textField.borderStyle = .none
        textField.layer.addSublayer(bottomLine)
    }
    
    static func styleFilledButton(_ button: UIButton) {
        button.backgroundColor = UIColor(red: 0, green: 153/255, blue: 153/255, alpha: 1)
        button.layer.cornerRadius = 20.0
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button: UIButton) {
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.secondaryLabel.cgColor
        button.layer.cornerRadius = 20.0
        button.tintColor = UIColor.label
    }
    
}
