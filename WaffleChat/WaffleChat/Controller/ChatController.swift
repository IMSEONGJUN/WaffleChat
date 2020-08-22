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

class ChatController: UIViewController {

    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var layout: UICollectionViewFlowLayout!
    
    var user: User?
    
    private lazy var customInputView = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width,
                                                                              height: 50))
    private var viewModel: ChatViewModel
    private var disposeBag = DisposeBag()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        configureCollectionView()
        bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: - Override
    override var inputAccessoryView: UIView? {
        return customInputView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    // MARK: - Custom Initializer
    init(user: User) {
        self.viewModel = ChatViewModel(user: user)
        print("init")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Initial Setup
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: configureFlowLayout())
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: MessageCell.reuseID)
    }
    
    func configureFlowLayout() -> UICollectionViewFlowLayout {
        layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: view.frame.width, height: 50)
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 50)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        return layout
    }
    
    
    // MARK: - Bind
    func bind() {
        viewModel.user
            .subscribe(onNext: { [weak self] in
                guard let user = $0 else { return }
                self?.user = user
                self?.configureNavigationBar(with: user.username, prefersLargeTitles: false)
            })
            .disposed(by: disposeBag)
        
        viewModel.messages
            .bind(to: collectionView.rx.items(cellIdentifier: MessageCell.reuseID,
                                              cellType: MessageCell.self)) {[weak self] indexPath, message, cell in
                                                var message = message
                                                message.user = self?.user
                                                cell.message = message
            }
            .disposed(by: disposeBag)

        customInputView.sendButton.rx.tap
            .flatMapLatest({
                Observable.zip(self.customInputView.messageInputTextView.rx.text.orEmpty, self.viewModel.user)
            })
            .filter({ $0.0 != "" && $0.1 != nil })
            .subscribe(onNext:{ [weak self] in
                APIManager.shared.uploadMessage($0.0, To: $0.1!) { (error) in
                    if let error = error {
                        print("Failed to upload message:", error)
                        return
                    }
                    
                    print("Succesfully uploaded message")
                }
                self?.customInputView.clearMessageText()
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext:{ _ in
                UIView.animate(withDuration: 0.5) {
                    self.customInputView.messageInputTextView.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
//        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
//            .subscribe(onNext:{ [weak self] noti -> Void in
//                guard let value = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
//                    return
//                }
//                let keyboardFrame = value.cgRectValue
//                self?.collectionView.contentOffset.y = (keyboardFrame.height + 50)
//            })
//            .disposed(by: disposeBag)
//
//        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
//            .subscribe(onNext: {[weak self] noti -> Void in
//                guard let value = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
//                    return
//                }
//                let keyboardFrame = value.cgRectValue
//                self?.collectionView.contentOffset.y = -(keyboardFrame.height + 50)
//            })
//            .disposed(by: disposeBag)
        
    }
}
