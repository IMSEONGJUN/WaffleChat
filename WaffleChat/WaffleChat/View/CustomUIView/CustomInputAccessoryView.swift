//
//  CustomInputAccessoryView.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/17.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CustomInputAccessoryView: UIView {

    // MARK: - Properties
    let messageInputTextView: UITextView = {
       let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.autocorrectionType = .no
        tv.isScrollEnabled = true
        return tv
    }()
    
    let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .white
        btn.setTitle("Send", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.setTitleColor(#colorLiteral(red: 0.6196078431, green: 0.4235294118, blue: 0.1254901961, alpha: 1), for: .normal)
        return btn
    }()
    
    let placeHolderLabel: UILabel = {
       let label = UILabel()
        label.text = "Enter Message"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    var disposeBag = DisposeBag()
    
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureShadow()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override var intrinsicContentSize: CGSize {
//        return .zero
//    }
    
    
    // MARK: - Initial Setup
    private func configureUI() {
        backgroundColor = .white
//        autoresizingMask = .flexibleHeight
        
        addSubview(sendButton)
        sendButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().inset(8)
            $0.width.equalTo(50)
            $0.height.equalTo(50)
        }
        
        addSubview(messageInputTextView)
        messageInputTextView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-5)
            $0.bottom.equalToSuperview().offset(-5)
        }
        
        addSubview(placeHolderLabel)
        placeHolderLabel.snp.makeConstraints {
            $0.leading.equalTo(messageInputTextView).offset(5)
            $0.centerY.equalTo(messageInputTextView)
        }
    }

    
    // MARK: - Bind
    private func bind() {
        NotificationCenter.default.rx.notification(UITextView.textDidChangeNotification)
        .subscribe(onNext: {[weak self] noti -> Void in
            guard let self = self else { return }
            self.placeHolderLabel.isHidden = !self.messageInputTextView.text.isEmpty
        })
        .disposed(by: disposeBag)
    }
    
    
    // MARK: - Helper
    func clearMessageText() {
        messageInputTextView.text = nil
        placeHolderLabel.isHidden = false
    }
    
    func configureShadow() {
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 10
        layer.shadowOffset = .init(width: 0, height: -8)
        layer.shadowColor = UIColor.lightGray.cgColor
    }
}
