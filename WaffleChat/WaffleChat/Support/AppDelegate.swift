//
//  AppDelegate.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/06/29.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import Firebase
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
//
//        if loginCheck() {
//            switchToConversationVC()
//        } else {
//            window = UIWindow(frame: UIScreen.main.bounds)
//            let loginController = LoginController.create(with: LoginViewModel())
//            window?.rootViewController = UINavigationController(rootViewController: loginController)
//            window?.makeKeyAndVisible()
//        }
        return true
    }
    
//    func switchToConversationVC() {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let window = UIWindow(frame: UIScreen.main.bounds)
//
//        let conversationVC = ConversationsController.create(with: ConversationViewModel())
//        window.rootViewController = UINavigationController(rootViewController: conversationVC)
//        window.makeKeyAndVisible()
//        appDelegate.window = window
//    }
//
//    func loginCheck() -> Bool {
//        return Auth.auth().currentUser != nil
//    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("Scene Session Configured!!!!!!!!!!!!!")
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

