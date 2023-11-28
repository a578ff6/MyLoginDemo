//
//  FirstViewController.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/28.
//

import UIKit

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
