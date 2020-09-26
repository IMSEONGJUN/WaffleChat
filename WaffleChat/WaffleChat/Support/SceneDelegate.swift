//
//  SceneDelegate.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/06/29.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import Firebase
import BackgroundTasks
import RxSwift
import RxCocoa

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        if loginCheck() {
            switchToConversationVC()
        } else {
            let loginController = LoginController.create(with: LoginViewModel())
            window?.rootViewController = UINavigationController(rootViewController: loginController)
            window?.makeKeyAndVisible()
        }

    }

    func switchToConversationVC() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.backgroundColor = .systemBackground
            let conversationVC = ConversationsController.create(with: ConversationViewModel())
            let rootVC = UINavigationController(rootViewController: conversationVC)
            window.rootViewController = rootVC
            
            let sceneDelegate = windowScene.delegate as? SceneDelegate
            window.makeKeyAndVisible()
            sceneDelegate?.window = window
        }
    }
    
    func loginCheck() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
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

extension SceneDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Update the app interface directly.
        
        // Play a sound.
//        completionHandler(UNNotificationPresentationOptions.sound)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.content.categoryIdentifier == "READ" {
            // Handle the actions for the expired timer.
            if response.actionIdentifier == "Read Message" {
                // Invalidate the old timer and create a new one. . .
                
                
            }
            else if response.actionIdentifier == "STOP_ACTION" {
                // Invalidate the timer. . .
            }
        }
        
        // Else handle actions for other notification types. . .
    }
    
    func configureUserNotification(fromUser: User, body: String) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Waffle Chat"
        content.body = "\(fromUser.fullname): " + body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: "NewMessage", content: content, trigger: trigger)
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
        
        let generalCategory = UNNotificationCategory(identifier: "GENERAL",
                                                     actions: [],
                                                     intentIdentifiers: [],
                                                     options: .customDismissAction)
        
        let readAction = UNNotificationAction(identifier: "Read Message",
                                              title: "Stop",
                                              options: .foreground)
        // Register the category.
        center.setNotificationCategories([generalCategory])
        let expiredCategory = UNNotificationCategory(identifier: "READ",
                                                     actions: [readAction],
                                                     intentIdentifiers: [],
                                                     options: UNNotificationCategoryOptions(rawValue: 0))
        
        // Register the notification categories.
        center.setNotificationCategories([generalCategory, expiredCategory])
    }

}
//        let center = UNUserNotificationCenter.current()
//        center.delegate = self
//        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
//            // Enable or disable features based on authorization.
//            if granted {
//                print("Authorized")
//            }
//        }
//
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.didReceiveMessage",
//                                        using: nil) { _ in
//            APIManager.shared.newMessage
//                .subscribe(onNext: { [weak self] in
//                    print("background Task!")
//                    self?.configureUserNotification(fromUser: $0.user, body: $0.recentMessage.text)
//                })
//                .disposed(by: self.disposeBag)
//        }
