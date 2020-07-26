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

class RegistrationViewModel {
    let profileImage = PublishRelay<UIImage?>()
    let email = PublishRelay<String>()
    let fullName = PublishRelay<String>()
    let userName = PublishRelay<String>()
    let password = PublishRelay<String>()
    
    lazy var isFormValid = Observable.combineLatest(email, fullName, userName, password, profileImage) {
        isValidEmailAddress(email: $0) && $1.count > 2 && $2.count > 2 && $3.count > 6 && $4 != nil
    }
}
