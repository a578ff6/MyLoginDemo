//
//  HomeViewController.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/28.
//

import UIKit
import FirebaseAuth
import Kingfisher

/// 確定登入、註冊成功，並提供登出功能
class HomeViewController: UIViewController {

    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    let imagePickerManager = ImagePickerManager()   // 測試
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        loadUserProfile()
    }
    
    // 會出現相簿、相機讓使用者將照片添加至userPhotoImageView以及更新Firebase
    @IBAction func selectePhotoButtonTapped(_ sender: UIButton) {
        imagePickerManager.presentImagePicker(in: self) { [weak self] selectedImage in
            guard let self = self, let image = selectedImage else { return }
            
            // 上傳圖片到 Firebase
            self.uploadProfileImageToFirebase(image)
        }
    }

    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            AlertService.showAlert(withTitle: "登出", message: "你已登出", inViewController: self) {
                // 在用戶點擊確定後，進行畫面跳轉
                self.transitionToFirstViewController()
            }
            
        } catch let signOutError as NSError {
            print("登出錯誤：\(signOutError)")
            AlertService.showAlert(withTitle: "錯誤", message: "登出錯誤：\(signOutError)", inViewController: self)
        }
    }
    
    /// 上傳圖片到 Firebase
    func uploadProfileImageToFirebase(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.uploadProfileImage(image, forUserID: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    print("圖片上傳成功: \(url)")
                    self?.userPhotoImageView.image = image
                    /// 更新 Firestore 中的用戶資料（大頭照）
                    FirebaseController.shared.updateUserProfilePhoto(uid: uid, photoURL: url) { result in
                        switch result {
                        case .success():
                            print("用戶資料更新成功")
                        case .failure(let error):
                            print("用戶資料更新失敗: \(error)")
                        }
                    }
                case .failure(let error):
                    print("圖片上傳失敗: \(error)")
                }
            }
        }

    }
    
    func loadUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.fetchUserProfile(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userProfile):
                    self?.fullNameLabel.text = "\(userProfile.firstName) \(userProfile.lastName)"
                    self?.emailLabel.text = userProfile.email
                    
                    if let photoURLString = userProfile.photoURL, let url = URL(string: photoURLString) {
                        self?.userPhotoImageView.kf.setImage(with: url, placeholder: UIImage(named: "person.crop.circle.fill"))
                    }
                    
                case .failure(let error):
                    print("錯誤： \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func setUpElements() {
        Utilities.styleFilledButton(signOutButton)
        Utilities.styleImageView(userPhotoImageView)
        Utilities.styleLabelWithUnderLine(fullNameLabel)
        Utilities.styleLabelWithUnderLine(emailLabel)
    }
    
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
