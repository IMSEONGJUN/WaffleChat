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



//    func makeInputDataContainerView(container: UIView, image: UIImage, textField: UITextField) {
//        let imageView = UIImageView(image: image)
//        let underline = UIView()
//
//        [imageView, textField, underline].forEach({ container.addSubview($0)})
//        underline.backgroundColor = .white
//        underline.snp.makeConstraints {
//            $0.bottom.trailing.equalToSuperview()
//            $0.leading.equalToSuperview().inset(10)
//            $0.height.equalTo(1.5)
//        }
//
//        imageView.snp.makeConstraints {
//            $0.centerY.equalToSuperview().offset(-2)
//            $0.leading.equalToSuperview().offset(10)
//            $0.width.height.equalTo(30)
//        }
//
//        textField.snp.makeConstraints {
//            $0.centerY.equalToSuperview()
//            $0.leading.equalTo(imageView.snp.trailing).offset(10)
//            $0.trailing.equalToSuperview().inset(10)
//        }
//    }