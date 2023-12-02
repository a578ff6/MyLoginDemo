//
//  SceneDelegate.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/28.
//


import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// 當場景與 App 連接時調用
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 確保使用的是 UIWindowScene
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 創建 UIWindow 並設置 rootViewController
        window = UIWindow(windowScene: windowScene)
        
        // 檢查 Firebase Auth 是否有已登入的用戶
        if Auth.auth().currentUser != nil {
            // 如果已登入，導航到主頁面
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let homeViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? HomeViewController {
                // 將 HomeViewController 設為 rootViewController
                window?.rootViewController = homeViewController
            }
        } else {
            // 如果未登入，導航到首頁
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let firstViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.firstViewController) as? FirstViewController {
                // 將 FirstViewController 嵌入 UINavigationController
                let navigationController = UINavigationController(rootViewController: firstViewController)

                window?.rootViewController = navigationController
            }
        }
        
        // 使 window 可見
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


