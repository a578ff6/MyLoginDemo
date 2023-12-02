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
 tony11@@
 */

import UIKit
import FirebaseAuth

// MARK: 負責處理用戶登入的視圖控制器
class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ActivityIndicatorManager.shared.activityIndicator(on: self.view)    // 設置活動指示器
        setUpElements()
        setUpHideKeyboardOnTap()
    }
    

    /// 處理登入按鈕
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        // 檢查電子郵件和密碼輸入框是否有輸入，並且不為空
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請輸入電子郵件和密碼", inViewController: self)
            return
        }
        
        // 啟動活動指示器
        ActivityIndicatorManager.shared.startLoading()
        
        // 呼叫 FirebaseController 進行登入
        FirebaseController.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                
                // 停止活動指示器
                ActivityIndicatorManager.shared.stopLoading()
                
                switch result {
                case .success(_):
                    
                    // 登入成功，進行頁面跳轉
                    self?.transitionToHome()
                    
                case .failure(let error):
                    
                    // 登入失敗，顯示錯誤訊息
                    // AlertService.showAlert(withTitle: "錯誤", message: "帳號或密碼錯誤", inViewController: self!)
                    AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
                }
            }
        }
   
    }
    
    /// 設定介面元素的外觀
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
