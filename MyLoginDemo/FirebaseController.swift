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

class FirebaseController {
    
    static let shared = FirebaseController()
    
    func creatUser(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Result< User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(FirebaseError.unknownError))
                return
            }
            
            /// 儲存額外訊息
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
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(FirebaseError.unknownError))
                return
            }
            
            completion(.success(user))
        }
    }
    
    enum FirebaseError: Error {
        case unknownError
    }
    
}

