//
//  ConversationCell.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/06/29.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {

    static let reuseIdentifier = "ConversationCell"
    
    // MARK: - Properties
    var conversation: Conversation? {
        didSet{
            configureData()
        }
    }
    
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let messageLabel = UILabel()
    
    
    // MARK: - initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setup
    func configureUI() {
        [profileImageView, nameLabel, messageLabel].forEach({contentView.addSubview($0)})
        
    }
    
    func configureData() {
        
    }
}
