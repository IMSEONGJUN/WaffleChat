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

struct ChatViewModel: ChatViewModelBindable {
    // Input
    let userData = BehaviorRelay<User?>(value: nil)
    let inputText = BehaviorRelay<String>(value: "")
    let sendButtonTapped = PublishSubject<Void>()
    
    // Output
    let isMessageUploaded: Driver<Bool>
    let messages = BehaviorRelay<[Message]>(value: [])
    
    var disposeBag = DisposeBag()
    
    init(user: User, model: APIManager = .shared) {
        self.userData.accept(user)
        
        model.fetchMessages(forUser: user)
            .catchErrorJustReturn([])
            .bind(to: messages)
            .disposed(by: disposeBag)
        
        let source = Observable
            .combineLatest(
                inputText,
                userData
            )
        
        isMessageUploaded = sendButtonTapped
            .withLatestFrom(source)
            .filter{ $0.0 != ""}
            .flatMapLatest{
                model.uploadMessage($0.0, To: $0.1!)
            }
            .asDriver(onErrorJustReturn: false)
    }
}

