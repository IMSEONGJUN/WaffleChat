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

protocol RegistrationViewModelBindable: ViewModelType {
    // Input
    var profileImage: PublishRelay<UIImage?> { get }
    var email: PublishRelay<String> { get }
    var fullName: PublishRelay<String> { get }
    var userName: PublishRelay<String> { get }
    var password: PublishRelay<String> { get }
    var signupButtonTapped: PublishRelay<Void> { get }
    
    // Output
    var isRegistering: Driver<Bool> { get }
    var isRegistered: Signal<Bool> { get }
    var isFormValid: Driver<Bool> { get }
}

final class RegistrationController: UIViewController, ViewType {

    // MARK: - Properties
    let plusPhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        btn.tintColor = .brown
        btn.contentMode = .scaleAspectFill
        btn.clipsToBounds = true
        return btn
    }()
    
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
    
    private lazy var stackContents = [
        emailContainer,
        fullNameContainer,
        userNameContainer,
        passwordContainer,
        signUpButton
    ]
    
    private let stack = UIStackView()
    
    var viewModel: RegistrationViewModelBindable!
    var disposeBag: DisposeBag!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Initial UI Setup
    func setupUI() {
        configureUIAttributeThings()
        configureGradientLayer()
        configurePlusPhotoButton()
        configureInputContextStackView()
        configureGoToLoginPageButton()
        setTapGesture()
    }
    
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
    
    
    // MARK: - Binding
    func bind() {
        
        // Input -> ViewModel
        signUpButton.rx.tap
            .bind(to: viewModel.signupButtonTapped)
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
        
        
        // viewModel -> Output
        viewModel.isFormValid
            .drive(with: self) { owner, isValid in
                owner.signUpButton.isEnabled = isValid
                owner.signUpButton.backgroundColor = isValid ? #colorLiteral(red: 0.9659136591, green: 0.6820907831, blue: 0.1123226724, alpha: 1) : #colorLiteral(red: 0.9379426837, green: 0.7515827417, blue: 0.31791839, alpha: 1)
            }
            .disposed(by: disposeBag)
        
        viewModel.profileImage
            .bind(to: rx.setProfileImage)
            .disposed(by: disposeBag)
        
        viewModel.isRegistering
            .drive(with: self) { owner, isRegistering in
                owner.showActivityIndicator(isRegistering, withText: isRegistering ? "Registering" : nil)
            }
            .disposed(by: disposeBag)
        
        viewModel.isRegistered
            .filter { $0 == true }
            .emit(with: self) { owner, _ in
                owner.switchToConversationVC()
            }
            .disposed(by: disposeBag)
        
        
        // UI Binding
        plusPhotoButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.didTapPlusPhotoButton(viewController: self)
            })
            .disposed(by: disposeBag)
        
        goToLoginPageButton.rx.tap
            .subscribe(onNext:{ [unowned self] in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        
        // Notification binding
        Observable.merge(
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification),
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
        )
        .subscribe(with: self) { owner, noti in
            if noti.name == UIResponder.keyboardWillShowNotification {
                let keyboardHeight = owner.getKeyboardFrameHeight(noti: noti)
                owner.view.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight - 8)
                return
            }
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut,
                           animations: {
                owner.view.transform = .identity
            })
        }
        .disposed(by: disposeBag)
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
        print("finished image pick")
        let image = info[.originalImage] as? UIImage
        viewModel.profileImage.accept(image)
        picker.dismiss(animated: true)
    }
}
