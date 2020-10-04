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
    let refreshPulled: PublishRelay<Void>
    let filterKey = PublishRelay<String>()
    let searchCancelButtonTapped = PublishRelay<Void>()
    
    // Output
    var users = BehaviorRelay<[User]>(value: [])
    let isNetworking: PublishRelay<Bool>
    let isSearching: BehaviorRelay<Bool>
    
    var disposeBag = DisposeBag()
    
    init(_ model: APIManager = .shared) {

        let onRefreshPulled = PublishRelay<Void>()
        refreshPulled = onRefreshPulled
        
        let baseUsersForFiltering = PublishRelay<[User]>()
        
        let onNetworking = PublishRelay<Bool>()
        isNetworking = onNetworking
        
        let onSearching = BehaviorRelay<Bool>(value: false)
        isSearching = onSearching
        
        
        // Initial Fetching
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
        
        
        // ReFetching by refreshing and canceling search
        let reFetchedUsers = Observable
            .merge(
                refreshPulled.asObservable(),
                searchCancelButtonTapped.asObservable()
            )
            .do(onNext: { onNetworking.accept(true) })
            .flatMapLatest(model.fetchUsers)
            .catchErrorJustReturn([])
            .share()
        
        reFetchedUsers
            .map{ _ in false }
            .bind(to: onNetworking)
            .disposed(by: disposeBag)
        
        reFetchedUsers
            .bind(to: users)
            .disposed(by: disposeBag)
        
        
        // Keyword for searching
        let inputText = filterKey
            .distinctUntilChanged()
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map{ $0.lowercased() }
            .share()
        
        Observable.combineLatest(
                inputText,
                baseUsersForFiltering
            )
            .filter { $0.0 != ""}
            .map{ text, users -> [User] in
                onSearching.accept(true)
                return users.filter{ $0.fullname.lowercased().contains(text)
                    || $0.username.lowercased().contains(text)}
            }
            .bind(to: users)
            .disposed(by: disposeBag)
        
        inputText
            .filter{ $0 == "" }
            .do(onNext: { _ in onSearching.accept(false) })
            .map { _ in Void()}
            .flatMapLatest(model.fetchUsers)
            .bind(to: users)
            .disposed(by: disposeBag)
    }
}
