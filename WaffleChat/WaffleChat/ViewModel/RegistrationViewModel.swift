//
//  RegistrationViewModel.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/07/19.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RegistrationViewModel {
    let profileImage = PublishRelay<UIImage?>()
    let email = PublishRelay<String>()
    let fullName = PublishRelay<String>()
    let userName = PublishRelay<String>()
    let password = PublishRelay<String>()
    
    var tempEmail = ""
    var tempFullName = ""
    var tempUserName = ""
    var tempPassword = ""
    var tempProfileImage = UIImage()
    
    var bag = DisposeBag()
    
    lazy var isFormValid = Observable.combineLatest(email, fullName, userName, password, profileImage) {
        isValidEmailAddress(email: $0) && $1.count > 2 && $2.count > 2 && $3.count > 6 && $4 != nil
    }
    
    func bind() {
        profileImage
            .subscribe(onNext:{
                guard let image = $0 else { return }
                self.tempProfileImage = image
            })
            .disposed(by: bag)
        
        email.subscribe(onNext: {
                self.tempEmail = $0
            })
            .disposed(by: bag)
        
        fullName.subscribe(onNext: {
                self.tempFullName = $0
            })
            .disposed(by: bag)
        
        userName.subscribe(onNext: {
                self.tempUserName = $0
            })
            .disposed(by:bag)
        
        password.subscribe(onNext:{
                self.tempPassword = $0
            })
            .disposed(by: bag)
    }
    
    func performRegistration() {
        
    }
}
