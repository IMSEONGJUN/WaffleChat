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

    let refreshPulled = PublishSubject<Void>()
    let isNetworking = PublishSubject<Bool>()
    
    let users = BehaviorRelay<[User]>(value: [])
    lazy var filteredUsers = users.value
    
    let filterKey = PublishRelay<String>()
    
    var disposeBag = DisposeBag()
    
    init() {
        fetchUsers()
        bind()
    }
    
    func fetchUsers() {
        APIManager.shared.fetchUsers()
            .do(onNext: { [weak self] _ in
                self?.isNetworking.onNext(false)
            })
            .do(onError: {
                print("failed to fetch users: ", $0)
            })
            .catchErrorJustReturn([])
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
        
        
        filterKey
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map{ $0.lowercased() }
            .subscribe(onNext: { [unowned self] str in
                if str == "" {
                    self.fetchUsers()
                    return
                }
                let filtered = filteredUsers.filter{ $0.fullname.lowercased().contains(str)
                                                    || $0.username.lowercased().contains(str) }
                self.users.accept(filtered)
            })
            .disposed(by: disposeBag)
        
    }
}

