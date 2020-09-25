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
    var profileImage = PublishRelay<UIImage?>()
    var email = PublishRelay<String>()
    var fullName = PublishRelay<String>()
    var userName = PublishRelay<String>()
    var password = PublishRelay<String>()
    var registrationValues = PublishRelay<Register>()
    var signupButtonTapped = PublishRelay<Void>()
    
    var isRegistering: Driver<Bool>
    var isRegistered: Signal<Bool>
    var isFormValid: Driver<Bool>
    
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
