//
//  NewMessageViewModel.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/10.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import RxSwift

class NewMessageViewModel {
    
//    var users = Bindable<[User]>()
    
    var users = PublishSubject<[User]>()
    
    init() {
        fetchUsers()
    }
    
//    func configure(completion: @escaping (Error?) -> Void) {
//        APIManager.shared.fetchUsers { [weak self] (users) in
//            self?.users.value = users
//            completion(nil)
//        }
//
//    }
    
    func fetchUsers()  {
        APIManager.shared.fetchUsers {[weak self] users in
            self?.users.onNext(users)
        }
    }
}
