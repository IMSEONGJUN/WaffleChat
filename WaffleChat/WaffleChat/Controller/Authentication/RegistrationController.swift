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
import JGProgressHUD

final class RegistrationController: UIViewController {

    // MARK: - Properties
    private let plusPhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        btn.tintColor = .brown
        btn.contentMode = .scaleAspectFill
        btn.clipsToBounds = true
        return btn
    }()
    
    let hud = JGProgressHUD(style: .dark)
    
    private lazy var emailContainer = InputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
    private let emailTextField = InputTextField(placeHolder: "Email")
    
    private lazy var fullNameContainer = InputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullNameTextField)
    private let fullNameTextField = InputTextField(placeHolder: "Full Name")
    
    private lazy var userNameContainer = InputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: userNameTextField)
    private let userNameTextField = InputTextField(placeHolder: "Username")
    
    private lazy var passwordContainer = InputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
    private let passwordTextField = InputTextField(placeHolder: "Password")
        
    private let signUpButton: UIButton = CustomButtonForAuth(title: "Sign Up", color: #colorLiteral(red: 0.9379426837, green: 0.7515827417, blue: 0.31791839, alpha: 1))
    
    private let goToLoginPageButton = BottomButtonOnAuth(firstText: "Already have an account? ", secondText: "Log In")
    
    private lazy var stackContents = [emailContainer,
                              fullNameContainer,
                              userNameContainer,
                              passwordContainer,
                              signUpButton]
    
    private let stack = UIStackView()
    
    let viewModel = RegistrationViewModel()
    var disposeBag = DisposeBag()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIAttributeThings()
        configureGradientLayer()
        configurePlusPhotoButton()
        configureInputContextStackView()
        configureGoToLoginPageButton()
        bind()
        setTapGesture()
    }
    
    
    // MARK: - Initial Setup
    private func configureUIAttributeThings() {
        passwordTextField.isSecureTextEntry = true
        emailTextField.keyboardType = .emailAddress
    }
    
    private func configurePlusPhotoButton() {
        view.addSubview(plusPhotoButton)
        plusPhotoButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(50)
            $0.width.height.equalTo(200)
        }
    }
    
    private func configureInputContextStackView() {
        stackContents.forEach({ stack.addArrangedSubview($0) })
        stack.axis = .vertical
        stack.spacing = 20
        stack.setCustomSpacing(10, after: passwordContainer)
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
    
    
    // MARK: - Binding for Async data stream
    private func bind() {
        userActionBinding()
        stateBinding()
        notificationBinding()
    }
    
    private func userActionBinding() {
        plusPhotoButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.didTapPlusPhotoButton(viewController: self)
            })
            .disposed(by: disposeBag)
        
        signUpButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.didTapSignUpButton()
            })
            .disposed(by: disposeBag)
        
        goToLoginPageButton.rx.tap
            .subscribe(onNext:{ [unowned self] in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
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
    
    private func stateBinding() {
        viewModel.isFormValid
            .subscribe(onNext: { [weak self] in
                print("Registration")
                self?.signUpButton.isEnabled = $0
                self?.signUpButton.backgroundColor = $0 ? #colorLiteral(red: 0.9659136591, green: 0.6820907831, blue: 0.1123226724, alpha: 1) : #colorLiteral(red: 0.9379426837, green: 0.7515827417, blue: 0.31791839, alpha: 1)
            })
            .disposed(by: disposeBag)
        
        viewModel.profileImage
            .subscribe(onNext: { [weak self] in
                print("changed image")
                guard let self = self else { return }
                self.plusPhotoButton.setImage($0?.withRenderingMode(.alwaysOriginal), for: .normal)
                self.plusPhotoButton.layer.cornerRadius = self.plusPhotoButton.frame.width / 2
                self.plusPhotoButton.layer.borderWidth = 3
                self.plusPhotoButton.layer.borderColor = UIColor.white.cgColor
            })
            .disposed(by: disposeBag)
        
        viewModel.isRegistering
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                if $0 {
                    self.hud.textLabel.text = "Registering..."
                    self.hud.show(in: self.view)
                } else {
                    self.hud.dismiss()
                }
            })
        .disposed(by: disposeBag)
        
    }
    
    private func notificationBinding() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .map { [weak self] noti -> CGFloat in
                guard let self = self else { fatalError() }
                return self.getKeyboardFrameHeight(noti: noti)
            }
            .subscribe(onNext: { [weak self] in
                self?.view.transform = CGAffineTransform(translationX: 0, y: -$0 - 8)
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
    private func didTapSignUpButton() {
        print("Sign Up")
        viewModel.isRegistering.accept(true)
        viewModel.performRegistration { [weak self] (err) in
            if let error = err {
                print("failed to registration: ", error)
                return
            }
            self?.viewModel.isRegistering.accept(false)
            self?.switchToConversationVC()
        }
    }
    
    
    // MARK: - Helper
    private func getKeyboardFrameHeight(noti: Notification) -> CGFloat {
        guard let value = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return 0
        }
        let keyboardHeight = value.cgRectValue.height
        let bottomSpace = self.view.frame.height - (self.stack.frame.origin.y + self.stack.frame.height)
        let lengthToMoveUp = keyboardHeight - bottomSpace
        return lengthToMoveUp
    }
}


// MARK: - UIImagePickerControllerDelegate
extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        viewModel.profileImage.accept(image)
        picker.dismiss(animated: true)
    }
}
