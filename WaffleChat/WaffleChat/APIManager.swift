//
//  APIManager.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/05.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import Firebase

class APIManager {
    static let shared = APIManager()
    
    private init() {}
    
    func fetchUser(uid: String, completion: @escaping (User) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            guard let dic = snapshot?.data() else { return }
            guard let user = User(user: dic) else { return }
            completion(user)
        }
    }
    
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        Firestore.firestore().collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("Failed to fetch users:", error)
                completion(.failure(error))
                return
            }
            
            var users = [User]()
            snapshot?.documents.forEach({ doc in
                let json = doc.data()
                guard let user = User(user: json),
                          user.uid != Auth.auth().currentUser?.uid else { return }
                users.append(user)
            })
            
            completion(.success(users))
        }
    }
    
    func uploadMessage(_ message: String, To user: User, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let message: [String: Any] = ["text": message,
                                   "fromId": currentUid,
                                    "toId": user.uid,
                                    "timestamp": Timestamp(date: Date())
                                  ]
        
        let ref = Firestore.firestore().collection("messages")
        ref.document(currentUid).collection(user.uid).addDocument(data: message) { (_) in
            NotificationCenter.default.post(name: Notifications.didFinishFetchMessage, object: nil)
            
            ref.document(user.uid).collection(currentUid).addDocument(data: message, completion: completion)
            
            ref.document(currentUid).collection("recent-messages").document(user.uid).setData(message)
            
            ref.document(user.uid).collection("recent-messages").document(currentUid).setData(message)
        }
    }
    
    func fetchMessages(forUser user: User, completion: @escaping ([Message]) -> Void) {
        var messages = [Message]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Firestore.firestore().collection("messages")
        let query = ref.document(currentUid).collection(user.uid).order(by: "timestamp")
        
        query.addSnapshotListener { (snapshot, error) in
            snapshot?.documentChanges.forEach({ (change) in
                if change.type == .added {
                    let dic = change.document.data()
                    messages.append(Message(dic: dic))
                    completion(messages)
                }
            })
        }
    }
    
    func fetchConversations(completion: @escaping (([Conversation]) -> Void) ) {
        var conversations = [Conversation]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Firestore.firestore().collection("messages").document(uid).collection("recent-messages").order(by: "timestamp")
        ref.addSnapshotListener { (snapshot, error) in
            snapshot?.documentChanges.forEach({ (change) in
                let dic = change.document.data()
                let message = Message(dic: dic)
                
                self.fetchUser(uid: message.toId) { (user) in
                    let conversation = Conversation(user: user, recentMessage: message)
                    conversations.append(conversation)
                    completion(conversations)
                }
            })
        }
        
    }
}
