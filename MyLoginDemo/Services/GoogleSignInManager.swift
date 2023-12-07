//
//  GoogleSignInManager.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/12/5.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import Firebase


/// 專門處理與 Google 登入相關的操作
class GoogleSignInManager {
    
    static let shared = GoogleSignInManager()

    /// 透過 Google 帳號進行登入
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        /// 獲取 clientID
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(FirebaseError.unknownError))
            return
        }
        
        /// 設定 Google 登入的配置。
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // 開始 Google 登入流程
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(FirebaseError.signInFailed(error.localizedDescription)))
                return
            }
            
            // 檢查登入結果和 ID Token。
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(FirebaseError.signInFailed("Google 登入失敗，無法獲取使用者資訊。")))
                return
            }
            
            /// 使用 ID Token 創建 Firebase 憑證。
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            // 使用 Firebase 憑證進行登入。
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(FirebaseError.signInFailed(error.localizedDescription)))      // Firebase 登入錯誤處理。
                    return
                }
                
                /// 獲取 firebaseUser。
                guard let firebaseUser = authResult?.user else {
                    completion(.failure(FirebaseError.signInFailed("Firebase 登入失敗")))             // Firebase 登入結果無效處理。
                    return
                }
                
                // 從 Google 使用者中獲取個人資料
                let firstName = user.profile?.givenName ?? ""
                let lastName = user.profile?.familyName ?? ""
                let email = user.profile?.email ?? ""
                let googlePhotoURL = user.profile?.imageURL(withDimension: 200)?.absoluteString ?? ""
                    
                // 檢查 Firestore 中是否已有該用戶的資料
                let db = Firestore.firestore()
                db.collection("users").document(firebaseUser.uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        // 如果用戶已存在，則不更新 photoURL。
                        completion(.success(firebaseUser))
                    } else {
                        // 如果用戶不存在，則創建新的用戶資料。
                        FirebaseController.shared.updateUserProfile(uid: firebaseUser.uid, firstName: firstName, lastName: lastName, email: email, photoURL: googlePhotoURL,completion: completion)
                    }
                }
                
            }
            
        }
        
    }

    
}


