//
//  UserProfile.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/30.
//

import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Codable {
    var firstName: String
    var lastName: String
    var email: String
}

