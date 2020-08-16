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
}
