//
//  ChatViewModel.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/20.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ChatViewModel {
    var user = BehaviorSubject<User?>(value: nil)
    var messages = BehaviorRelay<[Message]>(value: [])
    var disposeBag = DisposeBag()
    
    init(user: User) {
        self.user.onNext(user)
        bind()
    }
    
    func bind() {
        self.user
            .subscribe(onNext:{ [unowned self] in
                guard let user = $0 else { return }
                APIManager.shared.fetchMessages(forUser: user)
                    .bind(to: self.messages)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}

