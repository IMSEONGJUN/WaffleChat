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

final class NewMessageViewModel {

    var refreshPulled = PublishSubject<Void>()
    var isNetworking = PublishSubject<Bool>()
    var users = BehaviorRelay<[User]>(value: [])
    lazy var filteredUsers = users.value
    
    var disposeBag = DisposeBag()
    
    init() {
        bind()
        fetchUsers()
    }
    
    func fetchUsers() {
        APIManager.shared.fetchUsers()
            .do(onNext: { [weak self] _ in
                self?.isNetworking.onNext(false)
            })
            .bind(to: users)
            .disposed(by: disposeBag)
    }
    
    func bind()  {
        refreshPulled
            .do(onNext: { [unowned self] _ in
                self.fetchUsers()
            })
            .map{ _ in true }
            .bind(to: isNetworking)
            .disposed(by: disposeBag)
    }  
    
}
