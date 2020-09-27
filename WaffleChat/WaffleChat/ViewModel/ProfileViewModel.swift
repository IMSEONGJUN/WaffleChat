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

struct ProfileViewModel: ProfileViewModelBindable {
    // Output
    var user: Driver<User?>
    
    init(_ model: APIManager = .shared) {
        let uid = Auth.auth().currentUser?.uid
        user = model.fetchUser(uid: uid ?? "")
            .retry(2)
            .asDriver(onErrorJustReturn: nil)
    }
}

enum ProfileControllerTableViewCellType: Int, CaseIterable {
    
    case accountInfo
    case settings
    
    var description: String {
        switch self {
        case .accountInfo: return ProfileInfo.accountInfo
        case .settings: return ProfileInfo.settings
        }
    }
        
    var iconImageName: String {
        switch self {
        case .accountInfo: return IconImages.person
        case .settings: return IconImages.gear
        }
    }
        
        
}
