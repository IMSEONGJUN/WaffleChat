//
//  LoginController.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/07/01.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import JGProgressHUD

class LoginController: UIViewController {

    // MARK: - Properties
    private let logoImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: Images.logo)
        iv.layer.cornerRadius = 3
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var emailContainer = InputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
    private lazy var passwordContainer = InputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
    
    private let emailTextField = InputTextField(placeHolder: "Email")
    private let passwordTextField = InputTextField(placeHolder: "Password")
    
    private let loginButton = CustomButtonForAuth(title: "Log In", color: #colorLiteral(red: 0.9379426837, green: 0.7515827417, blue: 0.31791839, alpha: 1))
     
    private let goToSignUpPageButton = BottomButtonOnAuth(firstText: "Don't have an account? ", secondText: "Sign Up")
    
    var viewModel = LoginViewModel()
    var disposeBag = DisposeBag()
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginCheck()
        configureUI()
        binding()
    }
    
    
    // MARK: - Initial Setup
    private func configureUI() {
        configureDetailAttributesOfUI()
        configureGradientLayer()
        configureLogoImageView()
        configureGoToSignUpPageButton()
        configureAuthenticationStackView()
        configureTapGesture()
    }
    
    private func configureDetailAttributesOfUI() {
        emailTextField.keyboardType = .emailAddress
        passwordTextField.isSecureTextEntry = true
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .default
    }
    
    private func binding() {
        stateBinding()
        userActionBinding()
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
    
    
    // MARK: - Binding
    private func stateBinding() {
        viewModel.isValidForm
            .observeOn(MainScheduler.instance)
//            .map { _ in true}
//            .startWith(true) // viewModel.isValidForm Observable의 시퀀스가 시작되는 시점에 가장먼저 true를 방출하고 시작한다.
            .subscribe(onNext: { [weak self] in
                print($0)
                self?.loginButton.isEnabled = $0
                self?.loginButton.backgroundColor = $0 ? #colorLiteral(red: 0.9659136591, green: 0.6820907831, blue: 0.1123226724, alpha: 1) : #colorLiteral(red: 0.9379426837, green: 0.7515827417, blue: 0.31791839, alpha: 1)
            })
            .disposed(by: disposeBag)
    }
    
    private func userActionBinding() {
        emailTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.emailObservable)
            .disposed(by: disposeBag)

        passwordTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.passwordObservable)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.didTapLoginButton()
            })
            .disposed(by: disposeBag)
        
        goToSignUpPageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.didTapGoToSignUpPageButton()
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Action Handler
    private func didTapLoginButton() {
        print("login")
        showActivityIndicator(true)
        viewModel.performLogin { [weak self] (error) in
            guard let self = self else { return }
            self.showActivityIndicator(false)
            if let error = error {
                print("failed to login: ", error)
                return
            }
            print("Successfully logged in")
            self.switchToConversationVC()
        }
    }
    
    private func didTapGoToSignUpPageButton() {
        let vc = RegistrationController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
