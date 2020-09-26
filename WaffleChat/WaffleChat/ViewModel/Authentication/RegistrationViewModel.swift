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

struct RegistrationViewModel: RegistrationViewModelBindable {
    
    // MARK: - Properties
    let profileImage = PublishRelay<UIImage?>()
    let email = PublishRelay<String>()
    let fullName = PublishRelay<String>()
    let userName = PublishRelay<String>()
    let password = PublishRelay<String>()
    let registrationValues = PublishRelay<Register>()
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
