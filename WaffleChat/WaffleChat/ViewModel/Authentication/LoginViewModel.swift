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

class LoginViewModel {
    
    let emailObservable = BehaviorSubject<String>(value: "")
    let passwordObservable = BehaviorSubject<String>(value: "")
    
    lazy var isValidForm = Observable.combineLatest(emailObservable, passwordObservable) {
        isValidEmailAddress(email: $0) && $1.count > 6
    }
    
    func performLogin(completion: @escaping (Error?) -> Void) {
        guard let email = try? emailObservable.value() else { return }
        guard let password = try? passwordObservable.value() else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            completion(error)
        }
    }
    
}

// << 코드 작성 중 배운점 >>
// Observable.combineLatest는 합한 observable들 중에서 한개라도 값을 방출하면 합해진 모든 Observable에서 가장 최근에 방출된 값을 모두 묶어서 방출하는 새로운 Observable을 만든다.
// 그러나 Observable.merge는 합한 Observable중 가장 최근에 방출하는 1개의 값만을 내보내는 Observable을 만든다.
// ex)  Observable.merge(ob1, ob2)
//       .map{ value -> Int in
//         return Int(value)
//       }
