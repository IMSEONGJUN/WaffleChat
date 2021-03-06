//
//  Reactive+Ext.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/09/29.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import JGProgressHUD
import RxSwift
import RxCocoa


// MARK: - Reactive Custom Binder
extension Reactive where Base: RegistrationController {
    var setProfileImage: Binder<UIImage?> {
        return Binder(base) { base, image in
            base.plusPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            base.plusPhotoButton.layer.cornerRadius = base.plusPhotoButton.frame.width / 2
            base.plusPhotoButton.layer.borderWidth = 3
            base.plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        }
    }
}

extension Reactive where Base: UIRefreshControl {
    var spinner: Binder<Bool> {
        return Binder(base) { (refreshControl, isRefresh) in
            if isRefresh {
                refreshControl.beginRefreshing()
            } else {
                refreshControl.endRefreshing()
            }
        }
    }
}

extension ObservableType {
    
    func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}

