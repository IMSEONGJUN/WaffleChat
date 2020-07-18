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

class LoginViewModel {
    
    let emailObservable = PublishRelay<String>()
    let passwordObservable = PublishRelay<String>()
    
    lazy var isValidForm = Observable.combineLatest(emailObservable, passwordObservable) {
        self.isValidEmailAddress(email: $0) && $1.count > 6
    }
    
    func isValidEmailAddress(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}

// << 코드 작성 중 배운점 >>
// combineLatest는 합한 observalbe의 가장 최근에 방출된 값을 함께 방출하는 새로운 Observable을 만든다.
// 그러나 merge는 합한 Observable중 가장 최근에 방출하는 1개의 값만을 내보내는 Observable을 만든다.
//  Observable.merge(ob1, ob2)
//       .map{ value -> Int in
//         return Int(value)
//       }
