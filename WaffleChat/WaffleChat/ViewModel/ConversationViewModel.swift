//
//  ConversationViewModel.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/10.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ConversationViewModel {
    var conversations = BehaviorRelay<[Conversation]>(value: [])
    
    init() {
        fetchConversations()
    }
    
    func fetchConversations() {
        APIManager.shared.fetchConversations { (conversations) in
            self.conversations.accept(conversations)
        }
    }
}
