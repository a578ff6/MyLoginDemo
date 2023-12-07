//
//  AppDelegate.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/28.
//

import UIKit
import Firebase
import GoogleSignIn
import FacebookCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 初始化 Firebase，設置 Firebase 的第一步
        FirebaseApp.configure()
        
        // 初始化 Facebook SDK
        // 確保 Facebook SDK 正確地處理從 Facebook 登入返回的 URL。
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    
    /// 當 App 通過 URL 打開時調用
    func application(_ app: UIApplication, open url: URL,  options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        // 處理從 Facebook 登入返回的 URL
        // 確保 App 可以處理從 Facebook 登入流程返回的 URL。
        if ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation]) {
            return true
        }

      // 處理從 Google 登入返回的 URL
      return GIDSignIn.sharedInstance.handle(url)
        
    }
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

