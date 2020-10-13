//
//  Extensions.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/07/03.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import JGProgressHUD
import RxSwift
import RxCocoa

// MARK: - Global function
func isValidEmailAddress(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
}
