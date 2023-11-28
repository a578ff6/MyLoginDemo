//
//  LoginViewController.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/28.
//

/*
 tony12345@gmail.com
 12345678
 */

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!    
    
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
        
        // 使用 FirebaseController 進行登錄操作
        FirebaseController.shared.signIn(email: email, password: password) { [weak self] result in
            switch result {
            case .success(_):
                print("用戶登入成功")
                // 後續操作
                self?.transitionToHome()
            case .failure(let error):
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
            }
        }

    }
    
    func setUpElements() {
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
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

