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

struct NewMessageViewModel: NewMessageViewModelBindable {
    // Input
    var refreshPulled = PublishRelay<Void>()
    let filterKey = PublishRelay<String>()
    let searchCancelButtonTapped = PublishRelay<Void>()
    
    // Output
    var users = BehaviorRelay<[User]>(value: [])
    var isNetworking = PublishRelay<Bool>()
    
    var disposeBag = DisposeBag()
    
    init(_ model: APIManager = .shared) {

        let onRefreshPulled = PublishRelay<Void>()
        refreshPulled = onRefreshPulled
        
        let baseUsersForFiltering = PublishRelay<[User]>()
        let onNetworking = PublishRelay<Bool>()
        isNetworking = onNetworking
        
        let fetchedUsers = model
            .fetchUsers()
            .retryWhen{ _ in onRefreshPulled }
            .share()
        
        fetchedUsers
            .bind(to: users)
            .disposed(by: disposeBag)
        
        fetchedUsers
            .bind(to: baseUsersForFiltering)
            .disposed(by: disposeBag)
        
        let reFetchedUsers = Observable
            .merge(
                refreshPulled.asObservable(),
                searchCancelButtonTapped.asObservable()
            )
            .do(onNext: { onNetworking.accept(true) })
            .flatMapLatest(model.fetchUsers)
            .catchErrorJustReturn([])
        
        reFetchedUsers
            .map{ _ in false }
            .bind(to: onNetworking)
            .disposed(by: disposeBag)
        
        
        let inputText = filterKey
            .distinctUntilChanged()
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map{ $0.lowercased() }
            .share()
        
        Observable.combineLatest(inputText, baseUsersForFiltering)
            .filter { $0.0 != ""}
            .map{ text, users -> [User] in
                return users.filter{ $0.fullname.lowercased().contains(text)
                    || $0.username.lowercased().contains(text)}
            }
            .bind(to: users)
            .disposed(by: disposeBag)
        
        inputText
            .filter{ $0 == ""}
            .map { _ in Void()}
            .flatMapLatest(model.fetchUsers)
            .bind(to: users)
            .disposed(by: disposeBag)
    }
}
