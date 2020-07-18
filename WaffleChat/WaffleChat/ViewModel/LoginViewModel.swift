//
//  LoginViewModel.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/07/17.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation

class LoginViewModel {
    
    var email: String? { didSet{ checkValidty() } }
    var password: String? { didSet{ checkValidty() } }
    
    var isFormValid: Bool? {
        didSet{
            print("changed")
            formValidObserver?(isFormValid)
        }
    }
    
    var formValidObserver: ((Bool?) -> Void)?
    
    func checkValidty() {
        let valid = isValidEmailAddress(email: email ?? "") && password?.count ?? 0 > 6
        isFormValid = valid
    }
    
    func isValidEmailAddress(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
