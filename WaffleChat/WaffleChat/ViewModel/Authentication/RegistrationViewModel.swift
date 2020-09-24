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
    
    typealias Register = (profileImage: UIImage?, email: String, fullName: String, userName: String, password: String)
    
    // MARK: - Properties
    let profileImage = PublishRelay<UIImage?>()
    let email = PublishRelay<String>()
    let fullName = PublishRelay<String>()
    let userName = PublishRelay<String>()
    let password = PublishRelay<String>()
    let registrationValues = PublishRelay<Register>()
    let signupButtonTapped = PublishSubject<Void>()
    
    let isRegistering = BehaviorRelay<Bool>(value: false)
    let isRegistered = BehaviorRelay<Bool>(value: false)
    let isFormValid: Driver<Bool>
    
    var disposeBag = DisposeBag()
    
    // MARK: - Initializer
    init() {
        isFormValid = Observable
            .combineLatest(
                email,
                fullName,
                userName,
                password,
                profileImage
            )
            .map {
                isValidEmailAddress(email: $0) &&
                $1.count > 2 &&
                $2.count > 2 &&
                $3.count > 6 &&
                $4 != nil
            }
            .asDriver(onErrorJustReturn: false)
        
        let registrationValues = Observable
            .combineLatest(
                profileImage,
                email,
                fullName,
                userName,
                password
            )
            .map { ($0,$1,$2,$3,$4) }
            
        
        signupButtonTapped
            .withLatestFrom(registrationValues)
            .do(onNext:{ [unowned self] _ in self.isRegistering.accept(true) })
            .flatMapLatest{
                self.performRegistration(values: $0)
            }
            .subscribe(onNext: { [unowned self] in
                self.isRegistering.accept(!$0)
                self.isRegistered.accept($0)
            }, onError: { (error) in
                print("failed to register",error)
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Registration Logic
    func performRegistration(values: Register) -> Observable<Bool> {
        Observable.create { (observer) -> Disposable in
            Auth.auth().createUser(withEmail: values.email, password: values.password) { (result, error) in
                if let error = error {
                    observer.onError(error)
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
                    observer.onError(error)
                    return
                }
                
                ref.downloadURL { (url, error) in
                    if let error = error {
                        observer.onError(error)
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
                    observer.onError(error)
                    return
                }
                observer.onNext(true)
            }
            return Disposables.create()
        }
    }
}
