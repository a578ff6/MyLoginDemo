//
//  ForgotPasswordViewController.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/29.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請填寫您的信箱", inViewController: self)
            return
        }
        
        // 檢查電子郵件格式是否有效
        if !FirebaseController.isEmailvalid(email) {
            AlertService.showAlert(withTitle: "錯誤", message: "無效的電子郵件格式", inViewController: self)
            return
        }
        
        FirebaseController.shared.sendPasswordRest(email: email) { result in
            switch result {
            case .success(_):
                print("重置請求已發送")
                AlertService.showAlert(withTitle: "通知", message: "如果您的信箱已註冊，我們將發送密碼重置郵件給您。", inViewController: self) {
                    self.transitionToFirstViewController()
                }
            case .failure(let error):
                print("錯誤")
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            }
        }
    }
    
    func setUpElements() {
        Utilities.styleTextField(emailTextField)
        Utilities.styleFilledButton(resetPasswordButton)
    }
    
    /// 重置密碼後的轉場
    func transitionToFirstViewController() {
        let firstViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.firstViewController) as? FirstViewController
        
        // 加入轉場動畫
        let transition = CATransition()
        transition.type = CATransitionType.fade
        transition.duration = 0.5
        view.window?.layer.add(transition, forKey: kCATransition)
        
        view.window?.rootViewController = firstViewController
        view.window?.makeKeyAndVisible()
    }

}
