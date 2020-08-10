//
//  Bindable.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/07/27.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?) -> Void)?
    
    func bind(observer: @escaping (T?) -> Void) {
        self.observer = observer
    }
}
