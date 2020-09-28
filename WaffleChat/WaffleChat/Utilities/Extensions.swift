//
//  Extensions.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/07/03.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import JGProgressHUD
import RxSwift
import RxCocoa

// MARK: - Global function
func isValidEmailAddress(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
}


// MARK: - Reactive Custom Binder
extension Reactive where Base: RegistrationController {
    var setProfileImage: Binder<UIImage?> {
        return Binder(base) { base, image in
            base.plusPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            base.plusPhotoButton.layer.cornerRadius = base.plusPhotoButton.frame.width / 2
            base.plusPhotoButton.layer.borderWidth = 3
            base.plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        }
    }
}


// MARK: - UIViewController Ext
extension UIViewController {
    static let hud = JGProgressHUD(style: .dark)
    
    func configureGradientLayer() {
        let gradient = CAGradientLayer()
        let topColor = #colorLiteral(red: 1, green: 0.9944892197, blue: 0.7521914475, alpha: 1).cgColor
        let bottomColor = #colorLiteral(red: 0.6196078431, green: 0.4235294118, blue: 0.1254901961, alpha: 1).cgColor
        gradient.colors = [topColor, bottomColor]
        gradient.locations = [0, 1]
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
    }
    
    func switchToConversationVC() {
        if #available(iOS 13.0, *) {
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
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.backgroundColor = .systemBackground
            let conversationVC = ConversationsController.create(with: ConversationViewModel())
            let rootVC = UINavigationController(rootViewController: conversationVC)
            window.rootViewController = rootVC
            window.makeKeyAndVisible()
            appDelegate.window = window
        }

    }
    
    func doLogoutThisUser(completion: (Error?) -> Void) {
        do{
           try Auth.auth().signOut()
            completion(nil)
        } catch {
            print(error)
            completion(error)
        }
    }
    
    func switchToLoginVC() {
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.backgroundColor = .systemBackground
                let loginVC = LoginController.create(with: LoginViewModel())
                let rootVC = UINavigationController(rootViewController: loginVC)
                window.rootViewController = rootVC
                
                let sceneDelegate = windowScene.delegate as? SceneDelegate
                sceneDelegate?.window = window
                window.makeKeyAndVisible()
            }
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.backgroundColor = .systemBackground
            let loginVC = LoginController.create(with: LoginViewModel())
            let rootVC = UINavigationController(rootViewController: loginVC)
            window.rootViewController = UINavigationController(rootViewController: rootVC)
            window.makeKeyAndVisible()
            appDelegate.window = window
        }
    }
    
    func showActivityIndicator(_ show: Bool, withText text: String? = "Loading") {
        view.endEditing(true)
        UIViewController.hud.textLabel.text = text
        
        if show {
            UIViewController.hud.show(in: view)
        } else {
            UIViewController.hud.dismiss()
        }
    }
    
    func configureNavigationBar(with title: String, prefersLargeTitles: Bool) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.backgroundColor = #colorLiteral(red: 0.6196078431, green: 0.4235294118, blue: 0.1254901961, alpha: 1)
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
            navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
            navigationItem.title = title
            navigationController?.navigationBar.tintColor = .white
    //        navigationController?.navigationBar.isTranslucent = true
            navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
        }
    
    func didTapPlusPhotoButton<T: UIImagePickerControllerDelegate>(viewController: T)
                                                                            where T : UINavigationControllerDelegate {
        self.view.endEditing(true)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = viewController
        let alert = UIAlertController(title: "Select ImageSource", message: "", preferredStyle: .alert)
        
        let takePhoto = UIAlertAction(title: "Take photo", style: .default) { (_) in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            imagePicker.sourceType = .camera
            imagePicker.videoQuality = .typeHigh
            self.present(imagePicker, animated: true)
        }
        
        let album = UIAlertAction(title: "Photo Album", style: .default) { (_) in
            imagePicker.sourceType = .savedPhotosAlbum
            self.present(imagePicker, animated: true)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(takePhoto)
        alert.addAction(album)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    var topbarHeight: CGFloat {
        let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return statusBarHeight +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }

}


// MARK: - UIView Ext
extension UIView {
    func setupShadow(opacity: Float = 0, radius: CGFloat = 0, offset: CGSize = .zero, color: UIColor = .black) {
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
    }
}


//    func makeInputDataContainerView(container: UIView, image: UIImage, textField: UITextField) {
//        let imageView = UIImageView(image: image)
//        let underline = UIView()
//
//        [imageView, textField, underline].forEach({ container.addSubview($0)})
//        underline.backgroundColor = .white
//        underline.snp.makeConstraints {
//            $0.bottom.trailing.equalToSuperview()
//            $0.leading.equalToSuperview().inset(10)
//            $0.height.equalTo(1.5)
//        }
//
//        imageView.snp.makeConstraints {
//            $0.centerY.equalToSuperview().offset(-2)
//            $0.leading.equalToSuperview().offset(10)
//            $0.width.height.equalTo(30)
//        }
//
//        textField.snp.makeConstraints {
//            $0.centerY.equalToSuperview()
//            $0.leading.equalTo(imageView.snp.trailing).offset(10)
//            $0.trailing.equalToSuperview().inset(10)
//        }
//    }
