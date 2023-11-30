//
//  LoginViewController.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/28.
//

/*
 tony12345@gmail.com
 12345678
 a578ff6@gmail.com
 199122_cg96
 */

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }

    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        // 檢查電子郵件和密碼輸入框是否有輸入，並且不為空
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請輸入電子郵件和密碼", inViewController: self)
            return
        }
        
        // MARK: - （測試）使用 FirebaseController 進行登錄操作
        FirebaseController.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.transitionToHome()
                case .failure(let error):
                    if let errorCode = AuthErrorCode.Code(rawValue: (error as NSError).code) {
                        var message = ""
                        switch errorCode {
                        case .invalidEmail:
                            message = "電子郵件地址格式不正確。"
                        case .userNotFound:
                            message = "該電子郵件地址未註冊。"
                        case .wrongPassword:
                            message = "密碼不正確。"
                        default:
                            message = "登入時發生錯誤：\(error.localizedDescription)"
                        }
                        AlertService.showAlert(withTitle: "登入錯誤", message: message, inViewController: self!)
                    }
                }
            }
        }

        
        /*
        // 使用 FirebaseController 進行登錄操作
        FirebaseController.shared.signIn(email: email, password: password) { [weak self] result in
            switch result {
            case .success(_):
                self?.transitionToHome()
            case .failure(let error):
                print("錯誤詳情: \(error)")
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
            }
        }
        */

    }
    
    func setUpElements() {
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        Utilities.styleHollowButton(forgotPasswordButton)
    }
    
    /// 註冊或登入成功後的處理
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        // 設置轉場動畫
        let transition = CATransition()
        transition.type = CATransitionType.fade
        transition.duration = 0.5
        view.window?.layer.add(transition, forKey: kCATransition)
        
        // 切換 rootViewController
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
}

