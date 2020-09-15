//
//  CustomButtonForAuth.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/07/16.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

final class CustomButtonForAuth: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String, color: UIColor) {
        self.init(frame: .zero)
        setTitle(title, for: .normal)
        backgroundColor = color
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 10
        clipsToBounds = true
        isEnabled = false
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    }
}
