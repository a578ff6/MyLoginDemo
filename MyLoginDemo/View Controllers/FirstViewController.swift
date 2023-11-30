//
//  FirstViewController.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/28.
//

import UIKit

/// 一開始的登入、註冊選擇頁面
class FirstViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

       setUpElements()
    }
    
    func setUpElements() {
        Utilities.styleHollowButton(loginButton)
        Utilities.styleFilledButton(signUpButton)
    }

}
