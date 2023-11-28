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
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            errorLabel.text = "請輸入電子郵件和密碼"
            return
        }
        
        FirebaseController.shared.signIn(email: email, password: password) { [weak self] result in
            switch result {
            case .success(_):
                print("用戶登入成功")
                // 後續操作
            case .failure(let error):
                self?.errorLabel.text = "錯誤：\(error.localizedDescription)"
            }
        }
        

    }
    
}

