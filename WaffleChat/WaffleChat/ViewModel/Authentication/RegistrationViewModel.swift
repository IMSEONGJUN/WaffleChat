//
//  RegistrationViewModel.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/07/19.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

final class RegistrationViewModel {
    
    // MARK: - Properties
    let profileImage = PublishRelay<UIImage?>()
    
    let email = PublishRelay<String>()
    let fullName = PublishRelay<String>()
    let userName = PublishRelay<String>()
    let password = PublishRelay<String>()
    
    private var tempEmail = ""
    private var tempFullName = ""
    private var tempUserName = ""
    private var tempPassword = ""
    private var tempProfileImage = UIImage()
    
    var isRegistering = BehaviorRelay<Bool>(value: false)
    var bag = DisposeBag()
    
    lazy var isFormValid = Observable.combineLatest(email, fullName, userName, password, profileImage) {
        isValidEmailAddress(email: $0) && $1.count > 2 && $2.count > 2 && $3.count > 6 && $4 != nil
    }
    
    
    // MARK: - Initializer
    init() {
        bind()
    }
    
    // MARK: - Bind
    func bind() {
        profileImage
            .subscribe(onNext:{ [unowned self] in
                guard let image = $0 else { return }
                self.tempProfileImage = image
            })
            .disposed(by: bag)
        
        email
            .subscribe(onNext: { [unowned self] in
                self.tempEmail = $0
            })
            .disposed(by: bag)
        
        fullName
            .subscribe(onNext: { [unowned self] in
                self.tempFullName = $0
            })
            .disposed(by: bag)
        
        userName
            .subscribe(onNext: { [unowned self] in
                self.tempUserName = $0
            })
            .disposed(by:bag)
        
        password
            .subscribe(onNext:{ [unowned self] in
                self.tempPassword = $0
            })
            .disposed(by: bag)
    }
    
    
    // MARK: - Registration Logic
    func performRegistration(completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: tempEmail, password: tempPassword) { (result, error) in
            if let error = error {
                print(error)
                completion(error)
                return
            }
            self.saveImageToFirebase(completion: completion)
        }
    }
    
    private func saveImageToFirebase(completion: @escaping (Error?) -> Void){
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = tempProfileImage.jpegData(compressionQuality: 0.75) ?? Data()
        
        ref.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                completion(error)
                return
            }
            
            ref.downloadURL { (url, error) in
                if let error = error {
                    completion(error)
                    return
                }
                let imageURL = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageURL: imageURL, completion: completion)
            }
        }
    }
    
    private func saveInfoToFirestore(imageURL: String, completion: @escaping (Error?) -> Void) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData:[String: Any] = [
            "email": tempEmail,
            "fullname": tempFullName,
            "profileImageURL": imageURL,
            "uid": uid,
            "username": tempUserName.lowercased()
        ]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (error) in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
}
