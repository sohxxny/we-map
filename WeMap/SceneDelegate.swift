//
//  SceneDelegate.swift
//  WeMap
//
//  Created by Lee Soheun on 2024/01/24.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 로그인 여부 판단
        checkLogin(storyboard: UIStoryboard(name: "Main", bundle: nil), windowScene: windowScene)
    }
    
    // 로그인 여부를 판단하여 화면을 전환하는 함수
    func checkLogin(storyboard: UIStoryboard, windowScene: UIWindowScene) {
        
        var currentViewController: UIViewController
        if Auth.auth().currentUser == nil {
            currentViewController = storyboard.instantiateViewController(identifier: "SignInViewController")
            print("현재 로그인 상태가 아닙니다.")
        } else {
            // 사용자가 로그인한 상태인 경우 기본적으로 설정된 뷰 컨트롤러를 사용
            currentViewController = storyboard.instantiateInitialViewController()!
            print("로그인되었습니다.")
        }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = currentViewController
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

