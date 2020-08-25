//
//  MessageCell.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/18.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {
    
    static let reuseID = "MessageCell"
    
    // MARK: - Properties
    var message: Message? {
        didSet{
            configure()
        }
    }
    private let profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let textView: UITextView = {
       let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.textColor = .white
        return tv
    }()
    
    private let bubbleContainer: UIView = {
       let view = UIView()
        view.backgroundColor = .brown
        view.layer.cornerRadius = 12
        return view
    }()
    
    var textLeadingConst: NSLayoutConstraint!
    var texttrailingConst: NSLayoutConstraint!
    
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Initial Setup
    func configureUI() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(5)
            $0.leading.equalToSuperview().inset(10)
            $0.width.height.equalTo(44)
        }
        profileImageView.layer.cornerRadius = 44 / 2
        
        contentView.addSubview(bubbleContainer)
        contentView.addSubview(textView)
        
        bubbleContainer.snp.makeConstraints {
            $0.top.leading.equalTo(textView).offset(-4)
            $0.bottom.trailing.equalTo(textView).offset(4)
        }
        
        textView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.width.lessThanOrEqualTo(250)
        }
        textLeadingConst = textView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12)
        texttrailingConst = textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        
    }
    
    func configure() {
        guard let message = message else { return }
        let viewModel = MessageViewModel(message: message)
        bubbleContainer.backgroundColor = viewModel.messageBackgroundColor
        textView.textColor = viewModel.messageTextColor
        textView.text = message.text
        
        textLeadingConst.isActive = viewModel.leadingAnchorActive
        texttrailingConst.isActive = viewModel.trailingingAnchorActive
        
        profileImageView.isHidden = viewModel.shouldHideProfileImage
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
    }
}
