//
//  AlertService.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/29.
//

import Foundation
import UIKit

/// 警告視窗
class AlertService {
    /// 用於創建並顯示一個標準的警告彈窗
    static func showAlert(withTitle title: String, message: String, inViewController viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }

}

