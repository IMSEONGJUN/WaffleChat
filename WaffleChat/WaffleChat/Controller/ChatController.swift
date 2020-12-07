//
//  ChatController.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/16.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ChatViewModelBindable : ViewModelType {
    // Input
    var userData: BehaviorRelay<User?> { get }
    var inputText: BehaviorRelay<String> { get }
    var sendButtonTapped: PublishSubject<Void> { get }
    
    // Output
    var isMessageUploaded: Driver<Bool> { get }
    var messages: BehaviorRelay<[Message]> { get }
}

final class ChatController: UIViewController, ViewType {

    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var layout: UICollectionViewFlowLayout!
    
    private lazy var customInputView: CustomInputAccessoryView = {
       let iv = CustomInputAccessoryView()
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        iv.frame = frame
        return iv
    }()
    var viewModel: ChatViewModelBindable!
    var disposeBag: DisposeBag!
    
    private let tapGesture = UITapGestureRecognizer()
    private let coverView = UIView()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coverView.backgroundColor = .white
        coverView.frame = collectionView.bounds
        collectionView.addSubview(coverView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if collectionView.contentSize.height > collectionView.frame.height {
            let lengthToScroll = collectionView.contentSize.height - collectionView.frame.height
            collectionView.contentOffset.y = lengthToScroll
        }
        coverView.removeFromSuperview()
    }
    
    
    // MARK: - Initial UI Setup
    func setupUI() {
        configureCollectionView()
        configureCustomInputView()
        configureTapGesture()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureFlowLayout())
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(50)
        }
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: MessageCell.reuseID)
    }
    
    private func configureFlowLayout() -> UICollectionViewFlowLayout {
        layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 50)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        return layout
    }
    
    private func configureCustomInputView() {
        view.addSubview(customInputView)
        customInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(50)
        }
    }
    
    private func configureTapGesture() {
        collectionView.addGestureRecognizer(tapGesture)
    }
    
//    override var inputAccessoryView: UIView? {
//        return customInputView
//    }
//    
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
    
    // MARK: - Binding
    func bind() {
        
        // Input -> ViewModel
         customInputView.sendButton.rx.tap
             .bind(to: viewModel.sendButtonTapped)
             .disposed(by: disposeBag)
         
         customInputView.messageInputTextView.rx.text
             .orEmpty
             .bind(to: viewModel.inputText)
             .disposed(by: disposeBag)
        
        
        // ViewModel -> Output
        viewModel.userData
            .subscribe(onNext: { [weak self] in
                guard let user = $0 else { return }
                self?.configureNavigationBar(with: user.username, prefersLargeTitles: false)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.messages, viewModel.userData)
            .map{ (messages, user) -> [Message] in
                messages.map{ Message(original: $0, user: user!) }
            }
            .bind(to: collectionView.rx.items(cellIdentifier: MessageCell.reuseID,
                                              cellType: MessageCell.self)) { index, message, cell in
                                                cell.message = nil
                                                cell.textLeadingConst.isActive = false
                                                cell.texttrailingConst.isActive = false
                                                cell.timelabelLeadingConst.isActive = false
                                                cell.timelabelTrailingConst.isActive = false
                                                cell.message = message
            }
            .disposed(by: disposeBag)

        viewModel.isMessageUploaded
            .filter{ $0 }
            .drive(onNext: { [weak self] _ in
                self?.customInputView.clearMessageText()
            })
            .disposed(by: disposeBag)
       
        
        // UI Binding
        tapGesture.rx.event
            .subscribe(onNext: { [unowned self] _ in
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)

        
        // Notification Binding
        NotificationCenter.default.rx.notification(Notifications.didFinishFetchMessage)
            .subscribe(onNext:{ [weak self] (noti) in
                guard let self = self else { return }
                self.collectionView.layoutIfNeeded()
                if (self.collectionView.contentSize.height + self.topbarHeight) > self.collectionView.frame.height {
                    let count = self.viewModel.messages.value.count
                    self.collectionView.scrollToItem(at: IndexPath(item: count - 1, section: 0), at: .bottom, animated: true)
                    self.collectionView.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext:{ [weak self] noti in
                guard let self = self else { return }
                let height = self.getKeyboardFrameHeight(noti: noti)
                let bottomInset = self.view.safeAreaInsets.bottom
                
                if self.collectionView.contentSize.height + self.topbarHeight > self.view.frame.height - (height + self.customInputView.frame.height) {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -height + bottomInset)
                } else {
                    self.customInputView.transform = CGAffineTransform(translationX: 0, y: -height + bottomInset)
                }
                
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: {[weak self] noti in
                guard let self = self else { return }
                let height = self.getKeyboardFrameHeight(noti: noti)

                if self.collectionView.contentSize.height + self.topbarHeight > self.view.frame.height - (height + self.customInputView.frame.height) {
                    self.view.transform = .identity
                }
                self.customInputView.transform = .identity
            })
            .disposed(by: disposeBag)
        
    }
    
    
    // MARK: - Helper
    func getKeyboardFrameHeight(noti: Notification) -> CGFloat {
        guard let value = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            fatalError()
        }
        let keyboardFrame = value.cgRectValue
        return keyboardFrame.height
    }
}









//if (self.collectionView.contentSize.height + self.topbarHeight) > self.collectionView.frame.height {
//    let lengthToScroll = (self.collectionView.contentSize.height + self.topbarHeight) - self.collectionView.contentSize.height
//    self.collectionView.contentOffset.y = lengthToScroll + 32
/// CollectionView ContentOffSet Reference
///   let divisionIntValue = Int(collectionViewContentHeight / collectionViewHeight)
///   let remainder = collectionViewContentHeight.truncatingRemainder(dividingBy: collectionViewHeight)

// MARK: - Override
//    override var inputAccessoryView: UIView? {
//        return customInputView
//    }
//
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }

//                let count = self.viewModel.messages.value.count
//                self.collectionView.scrollToItem(at: IndexPath(item: count - 1, section: 0), at: .bottom, animated: true)
//                self.collectionView.layoutIfNeeded()
