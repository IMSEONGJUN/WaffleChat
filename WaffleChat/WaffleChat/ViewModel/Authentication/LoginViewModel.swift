//
//  LoginViewModel.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/07/17.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

final class LoginViewModel {
    
    let email = BehaviorSubject<String>(value: "")
    let password = BehaviorSubject<String>(value: "")
    let loginButtonTapped = PublishSubject<Void>()
    let isLoginCompleted: Signal<Bool>
    let isValidForm: Driver<Bool>
    
    init() {
        self.isValidForm = Observable
            .combineLatest(
                email,
                password
            )
            .map { isValidEmailAddress(email: $0) && $1.count > 6 }
            .asDriver(onErrorJustReturn: false)
        
        isLoginCompleted = loginButtonTapped
            .withLatestFrom(
                Observable.combineLatest(email, password)
            )
            .flatMapLatest {
                APIManager.shared.performLogin(email: $0, password: $1)
            }
            .asSignal(onErrorJustReturn: false)
    }
}
