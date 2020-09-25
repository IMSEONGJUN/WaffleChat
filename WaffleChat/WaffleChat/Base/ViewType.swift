//
//  ViewType.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/09/25.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - BaseView Protocol

protocol ViewType: class {
    var viewModel: ViewModelType! { get set }
    var disposeBag: DisposeBag! { get set }
    func bind()
}

extension ViewType where Self: UIViewController {
    static func create(with viewModel: ViewModelType) -> Self {
        let `self` = Self()
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        self.loadViewIfNeeded()
        self.bind()
        return self
    }
}
