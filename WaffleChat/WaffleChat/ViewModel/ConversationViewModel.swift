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

final class ConversationViewModel {
    var conversations = BehaviorRelay<[Conversation]>(value: [])
    var disposeBag = DisposeBag()
    
    init() {
        fetchConversations()
    }
    
    func fetchConversations() {
        APIManager.shared.fetchConversations()
            .do(onError: {
                print("failed to fetch conversations: ", $0)
            })
            .bind(to: conversations)
            .disposed(by: disposeBag)
    }
}
