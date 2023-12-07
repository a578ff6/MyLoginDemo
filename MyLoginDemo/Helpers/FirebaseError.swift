//
//  FirebaseError.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/12/7.
//

import Foundation

/// 自定義錯誤類型，用於處理 Firebase 相關錯誤
enum FirebaseError: Error {
    case unknownError
    case userCreationFailed(String)
    case signInFailed(String)
    case dataFetchFailed(String)
    case userProfileUpdateFailed(String)
    case passwordResetFailed(String)
    case documentNotExist
    case dataMappingFailed
    case userFetchFailed(String)

    /// 錯誤訊息
    var localizedDescription: String {
        switch self {
        case .unknownError:
            return "未知錯誤發生。"
        case .userCreationFailed(let message):
            return "用戶創建失敗：\(message)"
        case .signInFailed(let message):
            return "登入失敗：\(message)"
        case .dataFetchFailed(let message):
            return "資料擷取失敗：\(message)"
        case .userProfileUpdateFailed(let message):
            return "用戶資料更新失敗：\(message)"
        case .passwordResetFailed(let message):
            return "密碼重置失敗：\(message)"
        case .documentNotExist:
            return "文檔不存在。"
        case .dataMappingFailed:
            return "資料映射失敗。"
        case .userFetchFailed(let message):
            return "獲取用戶資訊失敗：\(message)"
        }
    }
}

