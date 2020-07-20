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
    
    let email = PublishRelay<String>()
    let fullName = PublishRelay<String>()
    let userName = PublishRelay<String>()
    let password = PublishRelay<String>()
    
    lazy var isFormValid = Observable.combineLatest([email, fullName, userName, password]) {
        isValidEmailAddress(email: $0[0]) && $0[1].count > 2 && $0[2].count > 2 && $0[3].count > 6
    }
}
