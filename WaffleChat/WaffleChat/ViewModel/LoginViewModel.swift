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
        isValidEmailAddress(email: $0) && $1.count > 6
    }
    
}

// << 코드 작성 중 배운점 >>
// Observable.combineLatest는 합한 observable들 중에서 한개라도 값을 방출하면 모든 Observable에서 가장 최근에 방출된 값을 모두 묶어서 방출하는 새로운 Observable을 만든다.
// 그러나 Observable.merge는 합한 Observable중 가장 최근에 방출하는 1개의 값만을 내보내는 Observable을 만든다.
// ex)  Observable.merge(ob1, ob2)
//       .map{ value -> Int in
//         return Int(value)
//       }
