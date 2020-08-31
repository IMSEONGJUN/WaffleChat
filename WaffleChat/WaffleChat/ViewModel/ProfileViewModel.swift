//
//  ProfileViewModel.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/31.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

class ProfileViewModel {
    
    var user = BehaviorRelay<User?>(value: nil)
    
    init() {
        print("viewModel")
        fetchUser()
    }
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        APIManager.shared.fetchUser(uid: uid) { (user) in
            self.user.accept(user)
        }
    }
    
}

enum ProfileControllerTableViewCellType: Int, CaseIterable {
    case accountInfo
    case settings
    
    var description: String {
        switch self {
        case .accountInfo: return "Account Info"
        case .settings: return "Settings"
        }
    }
        
    var iconImageName: String {
        switch self {
        case .accountInfo: return "person.circle"
        case .settings: return "gear"
        }
    }
        
        
}
