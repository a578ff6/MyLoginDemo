//
//  HomeViewController.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/28.
//

import UIKit
import FirebaseAuth
import Kingfisher

/// 負責處理包括顯示用戶資訊、登出功能，以及處理用戶大頭照的更換。
class HomeViewController: UIViewController {

    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    /// 負責管理圖片選擇器的實例
    let imagePickerManager = ImagePickerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        loadUserProfile()
    }
    
    // 當用戶點擊選擇照片按鈕
    @IBAction func selectePhotoButtonTapped(_ sender: UIButton) {
        imagePickerManager.presentImagePicker(in: self) { [weak self] selectedImage in
            guard let self = self, let image = selectedImage else { return }
            
            // 上傳圖片到 Firebase Storage 並更新用戶大頭照
            self.uploadProfileImageToFirebase(image)
        }
    }

    // 當用戶點擊登出按鈕
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()   // 嘗試從 FirebaseAuth 登出
            AlertService.showAlert(withTitle: "登出", message: "你已登出", inViewController: self) {
                // 在用戶點擊確定後，進行畫面跳轉
                self.transitionToFirstViewController()
            }
        } catch let signOutError as NSError {
            print("登出錯誤：\(signOutError)")
            AlertService.showAlert(withTitle: "錯誤", message: "登出錯誤：\(signOutError)", inViewController: self)
        }
    }
    
    /// 上傳用戶選擇的圖片到 Firebase Storage
    func uploadProfileImageToFirebase(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 調用 FirebaseController 的 uploadProfileImage 方法上傳圖片
        FirebaseController.shared.uploadProfileImage(image, forUserID: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    
                case .success(let url):
                    // 如果上傳成功，更新界面上的圖片
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
                    AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
                }
            }
        }

    }
    
    
    /// 從 Firebase 加載並顯示用戶的個人資料
    func loadUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.fetchUserProfile(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    
                case .success(let userProfile):
                    
                    self?.fullNameLabel.text = "\(userProfile.firstName) \(userProfile.lastName)"
                    self?.emailLabel.text = userProfile.email
                    
                    // 使用 Kingfisher 加載用戶的大頭照
                    if let photoURLString = userProfile.photoURL, let url = URL(string: photoURLString) {
                        // 請除緩存中的舊圖片
                        KingfisherManager.shared.cache.removeImage(forKey: url.absoluteString)
                        // 加載圖片
                        self?.userPhotoImageView.kf.setImage(with: url, placeholder: UIImage(named: "person.crop.circle.fill"))
                    }
                    
                case .failure(let error):
                    
                    print("錯誤： \(error.localizedDescription)")
                    AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
                }
            }
        }
    }
    
    
    /// 初始化介面元素的樣式
    func setUpElements() {
        Utilities.styleFilledButton(signOutButton)
        Utilities.styleImageView(userPhotoImageView)
        Utilities.styleLabelWithUnderLine(fullNameLabel)
        Utilities.styleLabelWithUnderLine(emailLabel)
    }
    
    
    /// 跳轉到首頁
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
