//
//  SignUpViewController.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/28.
//

import UIKit
import FirebaseAuth

// MARK: 負責處理用戶註冊的視圖控制器
class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
        
    }
    
    /// 處理註冊按鈕
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
        // 檢查 TextField 是否有輸入，並且不為空
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請填寫所有資料", inViewController: self)
            return
        }
        
        // 檢查電子郵件格式是否有效
        if !FirebaseController.isEmailvalid(email) {
            AlertService.showAlert(withTitle: "錯誤", message: "請輸入有效的電子郵件地址，例如：example@example.com", inViewController: self)
            return
        }
        
        // 檢查密碼是否符合規範
        if !FirebaseController.isPasswordValid(password) {
            AlertService.showAlert(withTitle: "錯誤", message: "密碼需至少包含8位字符，並包括至少一個小寫字母和一個特殊字符", inViewController: self)
            return
        }
        
        // 透過 FirebaseController 進行用戶註冊
        FirebaseController.shared.creatUser(email: email, password: password, firstName: firstName, lastName: lastName) { [weak self] result in
            switch result {
            case .success(_):
                
                print("用戶註冊成功")
                // 註冊成功後跳轉至首頁
                self?.transitionToHome()
                
            case .failure(let error):
                
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
            }
        }
        
    }
    
    /// 設定介面元素的樣式
    func setUpElements() {
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
    }
    
    /// 註冊成功後的頁面跳轉處理
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
