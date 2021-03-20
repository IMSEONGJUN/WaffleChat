//
//  APIManager.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/05.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import RxSwift
import RxCocoa
import UserNotifications

final class APIManager {
    
    static let shared = APIManager()
    
    var disposeBag = DisposeBag()
    
    let messageRef = Firestore.firestore().collection("messages")
    let userRef = Firestore.firestore().collection("users")
    
    
    private init() { }
    
    func fetchUsers() -> Observable<[User]> {
        return Observable<[User]>.create { (observer) -> Disposable in
            self.userRef.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Failed to fetch users:", error)
                    observer.onError(error)
                    return
                }
                
                var users = [User]()
                snapshot?.documents.forEach({ doc in
                    let json = doc.data()
                    guard let user = User(user: json),
                              user.uid != Auth.auth().currentUser?.uid else { return }
                    users.append(user)
                })
                
                observer.onNext(users)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        
    }
    
    func fetchUser(uid: String) -> Observable<User?> {
        return Observable.create { (observer) -> Disposable in
            self.userRef.document(uid).getDocument { (snapshot, error) in
                guard let dic = snapshot?.data(),
                    let user = User(user: dic) else { return }
                observer.onNext(user)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func fetchMessages(forUser user: User) -> Observable<[Message]> {
        guard let currentUid = Auth.auth().currentUser?.uid else { return Observable.empty() }
        var messages = [Message]()
        return Observable.create { (observer) -> Disposable in
            let query = self.messageRef.document(currentUid).collection(user.uid).order(by: "timestamp")
            
            query.addSnapshotListener { (snapshot, error) in
                snapshot?.documentChanges.forEach({ (change) in
                    if change.type == .added {
                        let dic = change.document.data()
                        messages.append(Message(dic: dic))
                    }
                })
                observer.onNext(messages)
            }
            
            return Disposables.create {
                observer.onCompleted()
            }
        }
    }
    
    func fetchConversations() -> Observable<[Conversation]> {
        guard let uid = Auth.auth().currentUser?.uid else { return Observable.empty() }
        let ref = self.messageRef.document(uid).collection("recent-messages").order(by: "timestamp")
        var conversations = [Conversation]()
        var sortedConversations = [Conversation]()
        return Observable.create { (observer) -> Disposable in
            ref.addSnapshotListener { (snapshot, error) in
                
                snapshot?.documentChanges.forEach({ (change) in
                    let dic = change.document.data()
                    let message = Message(dic: dic)
                    let id = message.toId == uid ? message.fromId : message.toId
                    
                    if conversations.contains(where: {$0.user.uid == id}) {
                        conversations.removeAll(where: {$0.user.uid == id})
                    }
                    
                    self.fetchUser(uid: id)
                        .subscribe(onNext:{ user -> Void in
                            guard let data = user else { return }
                            let conversation = Conversation(user: data, recentMessage: message)
                            conversations.insert(conversation, at: 0)
                            sortedConversations = conversations.sorted(by: {$0.recentMessage.timestamp.dateValue() > $1.recentMessage.timestamp.dateValue()})
                            observer.onNext(sortedConversations)
                        })
                        .disposed(by: self.disposeBag)
                })
                
            }
            
            return Disposables.create {
                print("Disposables")
                observer.onCompleted()
            }
        }
    }
    
    func uploadMessage(_ message: String, To user: User?) -> Observable<Bool> {
        guard let currentUid = Auth.auth().currentUser?.uid, let user = user else { return Observable.just(false)}
        
        let message: [String: Any] = [
                                      "text": message,
                                      "fromId": currentUid,
                                      "toId": user.uid,
                                      "timestamp": Timestamp(date: Date())
                                     ]
        
        let ref = Firestore.firestore().collection("messages")
        
        return Observable.create { (observer) -> Disposable in
            ref.document(currentUid).collection(user.uid).addDocument(data: message) { (_) in
                ref.document(user.uid).collection(currentUid).addDocument(data: message) { (_) in
                    ref.document(currentUid).collection("recent-messages").document(user.uid).setData(message)
                    ref.document(user.uid).collection("recent-messages").document(currentUid).setData(message)
                    observer.onNext(true)
                }
            }
            return Disposables.create{
                observer.onCompleted()
            }
        }
        
    }
}
