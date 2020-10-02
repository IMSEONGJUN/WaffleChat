//
//  ProfileCell.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/31.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

final class ProfileCell: UITableViewCell {
    
    // MARK: - Properties
    static let reuseID = "ProfileCell"
    
    var cellType: ProfileControllerTableViewCellType? {
        didSet{
            configureCellData()
        }
    }
    
    private lazy var iconContainer: UIView = {
       let view = UIView()
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        view.backgroundColor = #colorLiteral(red: 0.9379426837, green: 0.7515827417, blue: 0.31791839, alpha: 1)
        view.snp.makeConstraints {
            $0.width.height.equalTo(40)
        }
        view.layer.cornerRadius = 40 / 2
        view.clipsToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.snp.makeConstraints {
            $0.width.height.equalTo(28)
        }
        iv.layer.cornerRadius = 28 / 2
        iv.tintColor = .white
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Configure UI
    private func configure() {
        let stack = UIStackView(arrangedSubviews: [iconContainer, titleLabel])
        stack.spacing = 8
        stack.axis = .horizontal
        
        contentView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
        }
    }
    
    
    // MARK: - Cell Setter
    private func configureCellData() {
        guard let cellType = cellType else { return }
        iconImageView.image = UIImage(systemName: cellType.iconImageName)
        titleLabel.text = cellType.description
    }
}

