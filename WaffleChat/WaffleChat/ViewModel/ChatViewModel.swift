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
    var inputText = BehaviorRelay<String>(value: "")
    var sendButtonTapped = PublishSubject<Void>()
    var uploadedMessage = PublishSubject<Bool>()
    var disposeBag = DisposeBag()
    
    init(user: User) {
        self.user.onNext(user)
        bind()
    }
    
    func bind() {
        sendButtonTapped
            .flatMapLatest{[unowned self] in
                Observable.zip(self.inputText, self.user)
            }
            .subscribe(onNext: {
                APIManager.shared.uploadMessage($0.0, To: $0.1!) { (error) in
                    if let error = error {
                        print("Failed to upload message:", error)
                        return
                    }
                    self.uploadedMessage.onNext(true)
                    print("Succesfully uploaded message")
                }
            })
            .disposed(by: disposeBag)
        
        
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

