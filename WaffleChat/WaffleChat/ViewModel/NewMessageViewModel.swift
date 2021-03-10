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
    let isNetworking: Driver<Bool>
    
    var disposeBag = DisposeBag()
    
    init(_ model: APIManager = .shared) {

        // Proxy
        let onRefreshPulled = PublishRelay<Void>()
        refreshPulled = onRefreshPulled
        
        let onNetworking = PublishRelay<Bool>()
        isNetworking = onNetworking.asDriver(onErrorJustReturn: false)
        
        // Material
        let baseUsersForFiltering = PublishRelay<[User]>()
        let onSearching = BehaviorRelay<Bool>(value: false)
//      let someSub = PublishSubject<Void>()
        
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
        let refreshing = Observable
            .combineLatest(
                refreshPulled,
                onSearching
            )
            .filter{ !$1 }
            .mapToVoid()
        
        
        // merge할때는 합쳐지는 각각의 시퀀스가 갖는 값의 타입도 같아야 하는 것은 물론이며,
        // Observable, Subject 중 같은 wrapper타입끼리는 합쳐질 수 있으며
        // ex) Observable + Obsevable,
        // ( Observable + Subject ) Merge 가능
        // ( Relay + Relay ) Merge 불가 -> ( Relay.asObserable() + Relay.asObserable() )은 가능
        // ( Observable + Relay) Merge 불가 -> ( Observalble + Relay.asObserable() ) 은 가능함.
        let reFetchedUsers = Observable
            .merge(
                refreshing, // -> Observable
//              someSub     // -> Subject
                searchCancelButtonTapped.asObservable() // Relay.asObservable()
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
