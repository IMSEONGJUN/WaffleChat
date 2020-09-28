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

struct ConversationViewModel: ConversationViewModelBindable {
    //Output
    let conversations = BehaviorRelay<[Conversation]>(value: [])
    
    var disposeBag = DisposeBag()
    
    init(_ model: APIManager = .shared) {
        model.fetchConversations()
            .debug()
            .catchErrorJustReturn([])
            .bind(to: conversations)
            .disposed(by: disposeBag)
    }
}
