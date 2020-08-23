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

class ChatViewModel {
    var user = BehaviorSubject<User?>(value: nil)
    var messages = BehaviorRelay<[Message]>(value: [])
    
    init(user: User) {
        self.user.onNext(user)
        fetchMessages()
    }
    
    func fetchMessages() {
        guard let user = try? user.value() else { return }
        
        APIManager.shared.fetchMessages(forUser: user) { [weak self] (messages) in
            self?.messages.accept(messages)
        }
    }
}

