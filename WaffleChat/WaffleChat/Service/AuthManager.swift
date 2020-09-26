//
//  AuthManager.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/09/25.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

class AuthManager {
    
    init() { }
    
    var disposeBag = DisposeBag()
    
    func performLogin(email: String, password: String) -> Observable<Bool> {
        Observable.create { (observer) -> Disposable in
            Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
                if let error = error {
                    observer.onError(error)
                }
                observer.onNext(true)
            }
            
            return Disposables.create{
                observer.onCompleted()
            }
        }
    }
    
    // MARK: - Registration Logic
    func performRegistration(values: Register) -> Observable<Bool> {
        Observable.create { (observer) -> Disposable in
            Auth.auth().createUser(withEmail: values.email, password: values.password) { (result, error) in
                if let error = error {
                    print("failed to create User: ", error)
                    observer.onNext(false)
                    return
                }
                self.saveImageToFirebase(values: values)
                    .subscribe(onNext: {
                        observer.onNext($0)
                    })
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
        
    }
    
    private func saveImageToFirebase(values: Register) -> Observable<Bool> {
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = values.profileImage?.jpegData(compressionQuality: 0.75) ?? Data()
        
        return Observable.create { (observer) -> Disposable in
            ref.putData(imageData, metadata: nil) { (_, error) in
                if let error = error {
                    print("failed to save image to firestore: ", error)
                    observer.onNext(false)
                    return
                }
                
                ref.downloadURL { (url, error) in
                    if let error = error {
                        print("failed to download image URL: ", error)
                        observer.onNext(false)
                        return
                    }
                    let imageURL = url?.absoluteString ?? ""
                    self.saveInfoToFirestore(values: values, imageURL: imageURL)
                        .subscribe(onNext: {
                            observer.onNext($0)
                        })
                        .disposed(by: self.disposeBag)
                }
            }
            return Disposables.create()
        }
    }
    
    private func saveInfoToFirestore(values: Register, imageURL: String) -> Observable<Bool> {
        let uid = Auth.auth().currentUser?.uid ?? ""
        
        let docData:[String: Any] = [
            "email": values.email,
            "fullname": values.fullName,
            "profileImageURL": imageURL,
            "uid": uid,
            "username": values.userName.lowercased()
        ]
        return Observable<Bool>.create { (observer) -> Disposable in
            Firestore.firestore().collection("users").document(uid).setData(docData) { (error) in
                if let error = error {
                    print("failed to save user Info: ", error)
                    observer.onNext(false)
                    return
                }
                observer.onNext(true)
            }
            return Disposables.create()
        }
    }
    
}
