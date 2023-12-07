//
//  FacebookSignInManager.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/12/6.
//

import UIKit
import FirebaseAuth
import Firebase
import FacebookLogin
import FacebookCore


/// 專門處理與 Facebook 登入相關的操作
class FacebookSignInManager {
    
    
    static let shared = FacebookSignInManager()
    
    /// 使用 Facebook 帳號進行登入
    func signInWithFacebook(presentingViewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        
        // 初始化 Facebook LoginManager。
        let loginManager = LoginManager()
        
        // 開始 Facebook 登入流程，請求「基本公開資料」和「電子郵件地址」。
        loginManager.logIn(permissions: ["public_profile", "email"], from: presentingViewController) { (result, error) in
            // 處理錯誤情況。
            if let error = error {
                completion(.failure(error))
                return
            }
            
            /// 確保登入結果有效，並且用戶沒有取消登入。
            guard let result = result, !result.isCancelled,
                  let accessToken = AccessToken.current else {
                completion(.failure(FirebaseError.signInFailed("Facebook 登入被取消或未完成")))
                return
            }
            
            /// 使用從 Facebook 獲得的憑證來進行 Firebase 身份驗證。
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                // 處理 Firebase 登入錯誤。
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                /// 確保 Firebase Auth 回傳有效的用戶。
                guard let firebaseUser = authResult?.user else {
                    completion(.failure(FirebaseError.signInFailed("Firebase 登入失敗")))
                    return
                }
                
                // 從 Facebook 使用者中獲取個人資料
                let firstName = firebaseUser.displayName ?? "Facebook User"
                let lastName = ""
                let email = firebaseUser.email ?? ""
                let photoURL = firebaseUser.photoURL?.absoluteString ?? ""
                
                // 檢查 Firestore 中是否已有該用戶的資料
                let db = Firestore.firestore()
                db.collection("users").document(firebaseUser.uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        // 如果用戶已經存在，則無需更新資料。
                        completion(.success(firebaseUser))
                    } else {
                        // 如果用戶不存在於 Firestore 中，則創建新的用戶資料。
                        FirebaseController.shared.updateUserProfile(uid: firebaseUser.uid, firstName: firstName, lastName: lastName, email: email, photoURL: photoURL, completion: completion)
                    }
                }
            }
        }
    }
    

}



