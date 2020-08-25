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
    var disposeBag = DisposeBag()
    
    lazy var totalCountOfUsers = users.map { $0.count }
    
    init() {
        fetchUsers()
    }
    
    func fetchUsers()  {
        APIManager.shared.fetchUsers()
            .bind(to: users)
            .disposed(by: disposeBag)
    }  
    
}
