//
//  LoginController.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/07/01.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import SnapKit

class LoginController: UIViewController {

    // MARK: - Properties
    let logoImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: Images.logo)
        iv.layer.cornerRadius = 3
        iv.clipsToBounds = true
        return iv
    }()
    
    let emailContainer: UIView = {
       let view = UIView()
        return view
    }()
    
    let emailTextField: UITextField = {
       let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [.foregroundColor : UIColor.white])
        tf.textColor = .white
        tf.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return tf
    }()
    
    let passwordTextField: UITextField = {
       let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [.foregroundColor : UIColor.white])
        tf.textColor = .white
        tf.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return tf
    }()
    
    let passwordContainer: UIView = {
       let view = UIView()
        return view
    }()
    
    let loginButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("Log In", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 1, green: 0.698582075, blue: 0.1078745686, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return btn
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Initial Setup
    private func configureUI() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .default
        configureGradientLayer()
        configureLogoImageView()
        configureAuthenticationStackView()
        configureTapGesture()
    }
    
    private func configureGradientLayer() {
        let gradient = CAGradientLayer()
        let topColor = #colorLiteral(red: 1, green: 0.9944892197, blue: 0.7521914475, alpha: 1).cgColor
        let bottomColor = #colorLiteral(red: 0.6196078431, green: 0.4235294118, blue: 0.1254901961, alpha: 1).cgColor
        gradient.colors = [topColor, bottomColor]
        gradient.locations = [0, 1]
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
    }
    
    private func configureLogoImageView() {
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(100)
            $0.width.height.equalTo(120)
        }
    }
    
    private func configureAuthenticationStackView() {
        let stack = UIStackView(arrangedSubviews: [emailContainer, passwordContainer, loginButton])
        view.addSubview(stack)
        stack.axis = .vertical
        stack.spacing = 10
        [emailContainer, passwordContainer, loginButton].forEach({
            $0.snp.makeConstraints {
                $0.height.equalTo(50)
            }
        })
        
        stack.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(50)
        }
        
        configureEmailSection()
        configurePasswordSection()
    }
    
    private func configureEmailSection() {
        makeInputDataTextField(container: emailContainer, image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
    }
    
    private func configurePasswordSection() {
        makeInputDataTextField(container: passwordContainer, image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
    }
    
    private func configureTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    // MARK: - Action Handler

}
