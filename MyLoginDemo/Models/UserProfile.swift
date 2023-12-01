//
//  UserProfile.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/30.
//

import Foundation
import FirebaseFirestoreSwift

/// 用戶資訊
struct UserProfile: Codable {
    var firstName: String
    var lastName: String
    var email: String
    
    /// 大頭照
    var photoURL: String?
}


