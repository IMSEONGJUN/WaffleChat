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
    
    lazy var emailContainer = InputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
    let emailTextField = InputTextField(placeHolder: "Email")
    
    lazy var passwordContainer = InputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
    let passwordTextField: InputTextField = {
       let tf = InputTextField(placeHolder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let loginButton: UIButton = {
       let btn = CustomButtonForAuth(title: "Log In", color: #colorLiteral(red: 0.9379426837, green: 0.7515827417, blue: 0.31791839, alpha: 1))
        btn.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return btn
    }()
    // #colorLiteral(red: 1, green: 0.698582075, blue: 0.1078745686, alpha: 1)
    
    let goToSignUpPageButton: UIButton = {
        let btn = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ",
                                                        attributes: [.font: UIFont.systemFont(ofSize: 16),
                                                                     .foregroundColor : UIColor.white])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up",
                                                  attributes: [.font : UIFont.boldSystemFont(ofSize: 16),
                                                               .foregroundColor : UIColor.white]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        btn.addTarget(self, action: #selector(didTapGoToSignUpPageButton), for: .touchUpInside)
        return btn
    }()
    
    
    // MARK: - Life cycle
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
        configureGoToSignUpPageButton()
        configureAuthenticationStackView()
        configureTapGesture()
    }
    
    private func configureLogoImageView() {
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(100)
            $0.width.height.equalTo(120)
        }
    }
    
    private func configureGoToSignUpPageButton() {
        view.addSubview(goToSignUpPageButton)
        goToSignUpPageButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
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
    }
    
    private func configureTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    
    // MARK: - Action Handler
    @objc private func didTapLoginButton() {
        print("login")
    }
    
    @objc private func didTapGoToSignUpPageButton() {
        let vc = RegistrationController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
