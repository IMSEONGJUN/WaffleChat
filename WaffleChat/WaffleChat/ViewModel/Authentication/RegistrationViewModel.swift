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

typealias Register = (profileImage: UIImage?, email: String, fullName: String, userName: String, password: String)

struct RegistrationViewModel: RegistrationViewModelBindable {
    
    // MARK: - Properties
    let profileImage = PublishRelay<UIImage?>()
    let email = PublishRelay<String>()
    let fullName = PublishRelay<String>()
    let userName = PublishRelay<String>()
    let password = PublishRelay<String>()
    let signupButtonTapped = PublishRelay<Void>()
    
    let isRegistering: Driver<Bool>
    let isRegistered: Signal<Bool>
    let isFormValid: Driver<Bool>
    
    var disposeBag = DisposeBag()
    
    
    // MARK: - Initializer
    init(_ model: AuthManager = AuthManager()) {
        
        let onRegistering = PublishRelay<Bool>()
        isRegistering = onRegistering.asDriver(onErrorJustReturn: false)
        let onRegistered = PublishRelay<Bool>()
        isRegistered = onRegistered.asSignal(onErrorJustReturn: false)
        
        let registrationValues = Observable
            .combineLatest(
                profileImage,
                email,
                fullName,
                userName,
                password
            )
            .share()
        
        isFormValid = registrationValues
            .map {
                $0 != nil
                && isValidEmailAddress(email: $1)
                && $2.count > 2
                && $3.count > 2
                && $4.count > 6
            }
            .asDriver(onErrorJustReturn: false)
        
        signupButtonTapped
            .withLatestFrom(
                registrationValues
            )
            .do(onNext:{ _ in
                onRegistering.accept(true)
            })
            .flatMapLatest( model.performRegistration )
            .subscribe(onNext: {
                onRegistering.accept(false)
                onRegistered.accept($0 ? true : false)
            })
            .disposed(by: disposeBag)
    }
}
