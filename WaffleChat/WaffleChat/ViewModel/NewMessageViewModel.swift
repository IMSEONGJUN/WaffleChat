//
//  NewMessageViewModel.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/10.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NewMessageViewModel {
    
//    var users = Bindable<[User]>()
    
    var users = BehaviorRelay<[User]>(value: [])
    lazy var totalCountOfUsers = users.map { $0.count }
    
    init() {
        fetchUsers()
    }
    
    func fetchUsers()  {
        APIManager.shared.fetchUsers {[weak self] result in
            switch result {
            case .success(let users):
                self?.users.accept(users)
            case .failure(let error):
                print("Failed to fetch users: ", error)
            }
        }
    }  
    
}
