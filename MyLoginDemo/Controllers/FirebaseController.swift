//
//  FirebaseController.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/28.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

/// FirebaseController 類別用於集中處理 Firebase 相關的操作，如用戶註冊和登入。
class FirebaseController {
    
    /// 使用單例模式，確保整個 App 只有一個 FirebaseController 實例。
    static let shared = FirebaseController()
    
    /// 自定義錯誤類型
    enum FirebaseError: Error {
        case unknownError
    }
    
    /// 檢查電子郵件格式是否有效
    static func isEmailvalid(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    /// 檢查密碼是否符合要求（至少8位，包含小寫字母和特殊字符）
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
    /// 創建新用戶，並將用戶資料儲存到 Firestore。
    func creatUser(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Result< User, Error>) -> Void) {
        // 使用 FirebaseAuth 進行用戶註冊
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(FirebaseError.unknownError))
                return
            }
            
            /// 使用 Firestore 儲存用戶的額外資訊，如firstName、lastName、email
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "firstName": firstName,
                "lastName": lastName,
                "email": email
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(user))
                }
            }
            
        }
    }
    
    /// 登入，使用 FirebaseAuth 進行用戶登入。
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                print("觀察\(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(FirebaseError.unknownError))
                return
            }
            
            completion(.success(user))
        }
    }

    /*
     Auth.auth().signIn(withEmail: "peter@neverland.com", password: "123456") { result, error in
          guard error == nil else {
             print(error?.localizedDescription)
             return
          }
        print("success")
     }
     */
    
    /// 發送密碼重置郵件
    func sendPasswordRest(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))       // 發生錯誤，通過完成處理程序返回錯誤
            } else {
                completion(.success(()))          // 密碼重置郵件發送成功
            }
        }
    }
    
    /// 獲取用戶的資料
    func fetchUserProfile(uid: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { (document, error ) in
            if let document = document, document.exists {
                do {
                    let userProfile = try document.data(as: UserProfile.self)
                    completion(.success(userProfile))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(FirebaseError.unknownError))
            }
        }
    }
    
    // MARK: - 測試
    func uploadProfileImage(_ image: UIImage, forUserID userID: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return      // 處理無法轉換圖片的錯誤
        }
        
        let storageRef = Storage.storage().reference().child("profile_images").child("\(userID).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let url = url {
                    completion(.success(url))    // 可以選擇將 URL 存儲到 Firestore 的用戶文檔中
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }
}

