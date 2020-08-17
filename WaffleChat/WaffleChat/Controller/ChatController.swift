//
//  ChatController.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/16.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class ChatController: UIViewController {

    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var layout: UICollectionViewFlowLayout!
    
    private let user: User
    
    private lazy var customInputView: CustomInputAccessoryView = {
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        return iv
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        configureNavigationBar(with: user.username, prefersLargeTitles: false)
        configureCollectionView()
        
    }
    
    override var inputAccessoryView: UIView? {
        return customInputView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Custom Initializer
    init(user: User) {
        self.user = user
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
        
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: MessageCell.reuseID)
    }
    
    func configureFlowLayout() -> UICollectionViewFlowLayout {
        layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 50)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        return layout
    }
}


extension ChatController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCell.reuseID, for: indexPath) as! MessageCell
        return cell
    }
    
    
}
