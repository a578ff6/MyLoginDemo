//
//  FirebaseController.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/28.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


/// FirebaseController: 負責管理和執行所有 Firebase 相關操作
class FirebaseController {
    
    /// 單例模式，確保只有一個 FirebaseController 實例。
    static let shared = FirebaseController()
    
    
    // MARK: - 郵件、密碼檢查
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
    
    
    // MARK: - Email登入、註冊相關
    
    /// 創建新用戶，並將用戶資料儲存到 Firestore。
    func creatUser(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Result<User, Error>) -> Void) {
        
        // 使用 FirebaseAuth 進行用戶註冊
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(FirebaseError.userCreationFailed(error.localizedDescription)))
                return
            }
            
            /// 確認成功創建用戶
            guard let user = result?.user else {
                completion(.failure(FirebaseError.userCreationFailed("無法獲取用戶資料")))
                return
            }
            
            /// 使用 Firestore 儲存用戶的額外資訊，如firstName、lastName、emai、uid
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "uid": user.uid
            ]) { error in
                // 處理資料儲存時的錯誤
                if let error = error {
                    completion(.failure(FirebaseError.userCreationFailed(error.localizedDescription)))
                } else {
                    completion(.success(user))
                }
            }
            
        }
    }
    
    
    /// 使用 FirebaseAuth 進行用戶登入。
    /// - Parameters:
    ///   - email: 用戶的電子郵件地址。
    ///   - password: 用戶的密碼。
    ///   - completion: 完成處理程序，返回用戶登入的結果。
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        
        // 使用 FirebaseAuth 的 signIn 方法進行用戶登入。傳入電子郵件和密碼作為認證。
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("登錄錯誤代碼: \((error as NSError).code), 描述: \(error.localizedDescription)")
                completion(.failure(FirebaseError.signInFailed(error.localizedDescription)))
                return
            }
                    
            // 如果沒有錯誤發生，則檢查返回的用戶對象是否存在。
            guard let user = result?.user else {
                completion(.failure(FirebaseError.signInFailed("無法登入")))
                return
            }
            
            // 登入成功，回傳用戶對象。
            completion(.success(user))
        }
    }
    
    
    /// 獲取指定用戶ID的用戶資料。
    /// - Parameters:
    ///   - uid: 用戶ID，用於識別 Firestore 中的具體用戶文檔。
    // 獲取用戶資料函數
    func fetchUserProfile(uid: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        /// 獲取 Firestore 實例
        let db = Firestore.firestore()
        
        // 根據用戶ID訪問對應的文檔
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                completion(.failure(FirebaseError.dataFetchFailed(error.localizedDescription)))
                return
            }
            
            guard let document = document, document.exists, let userProfile = try? document.data(as: UserProfile.self) else {
                completion(.failure(FirebaseError.dataFetchFailed("用戶資料不存在或無法解析")))
                return
            }
            
            completion(.success(userProfile))
        }
    }
    
    
    /// 上傳用戶大頭照至 Firebase Storage 並更新 Firestore 中的用戶資料
    /// - Parameters:
    ///   - image: 要上傳的 UIImage 對象。
    ///   - userID: 上傳用戶的唯一識別碼。
    ///   - completion: 完成後的回調，返回操作的結果。
    func uploadAndUpdateProfileImage(_ image: UIImage, forUserID userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // 將 UIImage 轉換為 JPEG
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(FirebaseError.userProfileUpdateFailed("圖片轉換失敗")))
            return
        }

        // Firebase Storage 參考位置
        let storageRef = Storage.storage().reference().child("profile_images").child("\(userID).jpg")

        // 上傳圖片
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(FirebaseError.userProfileUpdateFailed(error.localizedDescription)))
                return
            }

            // 獲取並返回圖片的 URL
            storageRef.downloadURL { url, error in
                if let url = url {
                    // 更新 Firestore 中的用戶資料
                    let db = Firestore.firestore()
                    db.collection("users").document(userID).updateData(["photoURL": url.absoluteString]) { error in
                        if let error = error {
                            completion(.failure(FirebaseError.userProfileUpdateFailed(error.localizedDescription)))
                        } else {
                            completion(.success(()))
                        }
                    }
                } else if let error = error {
                    completion(.failure(FirebaseError.userProfileUpdateFailed(error.localizedDescription)))
                }
            }
        }
    }
    
    
    /// 更新 Firestore 中的用戶資料。（google、facebook使用）
    func updateUserProfile(uid: String, firstName: String, lastName: String, email: String, photoURL: String, completion: @escaping (Result<User, Error>) -> Void) {
        
        let db = Firestore.firestore()
        
        // 設置用戶資料，包括姓名、電子郵件和大頭照 URL。
        db.collection("users").document(uid).setData([
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "photoURL": photoURL
        ]) { error in
            if let error = error {
                // 如果在設置過程中發生錯誤，返回詳細的錯誤訊息。
                completion(.failure(FirebaseError.dataFetchFailed("更新 Firestore 用戶資料時發生錯誤：\(error.localizedDescription)")))
            } else {
                // 如果成功，獲取 Firebase Auth 中的 User 對象。
                if let user = Auth.auth().currentUser {
                    completion(.success(user))
                } else {
                    // 如果無法獲取 User 對象，返回一個自定義錯誤訊息。
                    completion(.failure(FirebaseError.userFetchFailed("無法從 Firebase Auth 獲取用戶資訊。")))
                }
            }
        }
        
        
    }
    
    
    // MARK: - 密碼重置相關
    
    /// 發送密碼重置郵件
    func sendPasswordRest(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(FirebaseError.passwordResetFailed(error.localizedDescription)))       // 發生錯誤，通過 completion 返回錯誤

            } else {
                completion(.success(()))          // 密碼重置郵件發送成功
            }
        }
    }


}



// MARK: - 原始版本將上傳圖片及更新資料分開來

/*
    /// 上傳用戶大頭照至 Firebase Storage
    /// - Parameters:
    ///   - image: 要上傳的 UIImage 對象。
    ///   - userID: 上傳用戶的唯一識別碼。
    func uploadProfileImage(_ image: UIImage, forUserID userID: String, completion: @escaping (Result<URL, Error>) -> Void) {

        /// 將 UIImage 轉換為 JPEG ，大小設置為 0.5 。
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return
        }

        /// 指向 Firebase Storage 中特定位置的參考，用於存儲大頭照。
        let storageRef = Storage.storage().reference().child("profile_images").child("\(userID).jpg")

        // 上傳圖片數據到指定的存儲位置。
        storageRef.putData(imageData, metadata: nil) { metadata, error in

            // 如果上傳過程中出現錯誤。
            if let error = error {
                completion(.failure(error))
                return
            }

            // 上傳成功後，獲取並返回圖片的 URL。
            storageRef.downloadURL { url, error in
                if let url = url {
                    completion(.success(url))         // 將 URL 存儲到 Firestore 的用戶文檔中
                } else if let error = error {
                    completion(.failure(error))       // 獲取 URL 過程出現錯誤。
                }
            }
        }
    }


    /// 更新用戶的大頭照 URL 至 Firestore
    /// - Parameters:
    ///   - uid: 用戶的唯一識別碼（UID）。
    ///   - photoURL: 上傳後圖片的 URL。
    func updateUserProfilePhoto(uid: String, photoURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {

        /// 獲取 Firestore 的實例
        let db = Firestore.firestore()

        // 更新指定用戶文檔的 'photoURL' 欄位
        db.collection("users").document(uid).updateData(["photoURL": photoURL.absoluteString]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
*/
