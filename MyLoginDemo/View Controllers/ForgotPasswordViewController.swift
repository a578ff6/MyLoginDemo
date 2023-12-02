//
//  ForgotPasswordViewController.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/29.
//

import UIKit
import FirebaseAuth


// MARK: 負責處理用戶忘記密碼的視圖控制器
class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ActivityIndicatorManager.shared.activityIndicator(on: self.view)    // 設置活動指示器
        setUpElements()
        setUpHideKeyboardOnTap()
    }
    
    
    /// 處理重置密碼按鈕
    @IBAction func resetPasswordButtonTapped(_ sender: UIButton) {
        // 驗證 emailTextField 是否已輸入
        guard let email = emailTextField.text, !email.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請填寫您的信箱", inViewController: self)
            return
        }
        
        // 檢查電子郵件格式是否有效
        if !FirebaseController.isEmailvalid(email) {
            AlertService.showAlert(withTitle: "錯誤", message: "無效的電子郵件格式", inViewController: self)
            return
        }
        
        
        ActivityIndicatorManager.shared.startLoading()          // 啟動活動指示器
        
        
        // 發送密碼重置請求
        FirebaseController.shared.sendPasswordRest(email: email) { result in
            DispatchQueue.main.async {
                
                ActivityIndicatorManager.shared.stopLoading()   // 停止活動指示器
                
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
    }
    
    
    /// 設定介面元素的樣式
    func setUpElements() {
        Utilities.styleTextField(emailTextField)
        Utilities.styleFilledButton(resetPasswordButton)
    }
    
    
    /// 重置密碼後的轉場
    func transitionToFirstViewController() {
        let firstViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.firstViewController) as? FirstViewController
        
        // 創建導航控制器並將 FirstViewController 設為其根視圖控制器
        let navigationController = UINavigationController(rootViewController: firstViewController!)

        // 加入轉場動畫
        let transition = CATransition()
        transition.type = CATransitionType.fade
        transition.duration = 0.5
        view.window?.layer.add(transition, forKey: kCATransition)
        
        view.window?.rootViewController = navigationController
        view.window?.makeKeyAndVisible()
    }


}
