//
//  ProfileHeader.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/31.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileHeader: UIView {
    
    // MARK: - Properties
    
    var user = PublishRelay<User>()
    var disposeBag = DisposeBag()
    
    let dismissButton: UIButton = {
       let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark",
                             withConfiguration: UIImage.SymbolConfiguration(scale:.large))?
                            .withRenderingMode(.alwaysOriginal), for: .normal)
        btn.tintColor = .black
        return btn
    }()
    
    let profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 4
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let fullNameLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    let userNameLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Initial Setup
    func configureUI() {
        configureGradientLayer()
        [dismissButton, profileImageView].forEach({addSubview($0)})
        
        dismissButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(45)
            $0.leading.equalToSuperview().offset(9)
            $0.width.height.equalTo(45)
        }
        
        profileImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(80)
            $0.width.height.equalTo(200)
        }
        profileImageView.layer.cornerRadius = 200 / 2
        
        let stack = UIStackView(arrangedSubviews: [fullNameLabel, userNameLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.centerX.equalTo(profileImageView)
            $0.top.equalTo(profileImageView.snp.bottom).offset(15)
        }
    }
    
    
    func configureGradientLayer() {
        let gradient = CAGradientLayer()
        let topColor = #colorLiteral(red: 1, green: 0.9944892197, blue: 0.7521914475, alpha: 1).cgColor
        let bottomColor = #colorLiteral(red: 0.6196078431, green: 0.4235294118, blue: 0.1254901961, alpha: 1).cgColor
        gradient.colors = [topColor, bottomColor]
        gradient.locations = [0, 1]
        layer.addSublayer(gradient)
        gradient.frame = bounds
    }
    
    
    // MARK: - Bind
    func bind() {
        user
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                self.fullNameLabel.text = $0.fullname
                self.userNameLabel.text = "@" + $0.username
                guard let url = URL(string: $0.profileImageUrl) else { return }
                self.profileImageView.sd_setImage(with: url)
            })
            .disposed(by: disposeBag)
    }
}
