//
//  RegistrationController.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/07/01.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RegistrationController: UIViewController {

    // MARK: - Properties
    private let plusPhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        btn.tintColor = .brown
        btn.addTarget(self, action: #selector(didTapPlusPhotoButton), for: .touchUpInside)
        return btn
    }()
    
    private lazy var emailContainer = InputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
    private let emailTextField = InputTextField(placeHolder: "Email")
    
    private lazy var fullNameContainer = InputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullNameTextField)
    private let fullNameTextField = InputTextField(placeHolder: "Full Name")
    
    private lazy var userNameContainer = InputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: userNameTextField)
    private let userNameTextField = InputTextField(placeHolder: "Username")
    
    private lazy var passwordContainer = InputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
    private let passwordTextField: InputTextField = {
        let tf = InputTextField(placeHolder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let signUpButton: UIButton = {
       let btn = CustomButtonForAuth(title: "Sign Up", color: #colorLiteral(red: 0.9379426837, green: 0.7515827417, blue: 0.31791839, alpha: 1))
        btn.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        return btn
    }()
    
    let goToLoginPageButton: UIButton = {
        let btn = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ",
                                                        attributes: [.font: UIFont.systemFont(ofSize: 16),
                                                                     .foregroundColor : UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Log In",
                                                  attributes: [.font : UIFont.boldSystemFont(ofSize: 16),
                                                               .foregroundColor : UIColor.white]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        btn.addTarget(self, action: #selector(didTapGoToLoginPageButton), for: .touchUpInside)
        return btn
    }()
    
    lazy var stackContents = [emailContainer,fullNameContainer,userNameContainer,passwordContainer,signUpButton]
    let stack = UIStackView()
    
    let viewModel = RegistrationViewModel()
    var disposeBag = DisposeBag()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGradientLayer()
        configurePlusPhotoButton()
        configureInputContextStackView()
        configureGoToLoginPageButton()
        bind()
        setTapGesture()
    }
    
    
    // MARK: - Initial Setup
    private func configurePlusPhotoButton() {
        view.addSubview(plusPhotoButton)
        plusPhotoButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(100)
            $0.width.height.equalTo(200)
        }
    }
    
    private func configureInputContextStackView() {
        stackContents.forEach({ stack.addArrangedSubview($0) })
        stack.axis = .vertical
        stack.spacing = 20
        
        stackContents.forEach({
            $0.snp.makeConstraints {
                $0.height.equalTo(50)
            }
        })
        
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalTo(plusPhotoButton.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(50)
        }
    }
    
    private func configureGoToLoginPageButton() {
        view.addSubview(goToLoginPageButton)
        goToLoginPageButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func setTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    private func bind() {
        UIbinding()
        dataBinding()
        notificationBinding()
    }
    
    private func UIbinding() {
        emailTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        fullNameTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.fullName)
            .disposed(by: disposeBag)
        
        userNameTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.userName)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
    }
    
    private func dataBinding() {
        viewModel.isFormValid
            .subscribe(onNext: { [weak self] in
                self?.signUpButton.isEnabled = $0
                self?.signUpButton.backgroundColor = $0 ? #colorLiteral(red: 0.9659136591, green: 0.6820907831, blue: 0.1123226724, alpha: 1) : #colorLiteral(red: 0.9379426837, green: 0.7515827417, blue: 0.31791839, alpha: 1)
            })
            .disposed(by: disposeBag)
    }
    
    private func notificationBinding() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .map { [weak self] noti -> CGFloat? in
                guard let self = self else { return nil }
                guard let value = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                    fatalError("no keyboard frame")
                }
                let keyboardHeight = value.cgRectValue.height
                let bottomSpace = self.view.frame.height - (self.stack.frame.origin.y + self.stack.frame.height)
                let lengthToMoveUp = keyboardHeight - bottomSpace
                return lengthToMoveUp
            }
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let value = $0 else {return}
                self.view.transform = CGAffineTransform(translationX: 0, y: -value - 8)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] noti -> Void in
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 1,
                               options: .curveEaseOut,
                               animations: {
                    self?.view.transform = .identity
                })
            })
            .disposed(by: disposeBag)
        
    }
    
    
    // MARK: - Action Handler
    @objc private func didTapPlusPhotoButton() {
        
    }
    
    @objc private func didTapSignUpButton() {
        print("Sign Up")
    }
    
    @objc private func didTapGoToLoginPageButton() {
        navigationController?.popViewController(animated: true)
    }
}
