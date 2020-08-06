//
//  Models.swift
//  WaffleChat
//
//  Created by SEONGJUN on 2020/08/06.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation


struct Message {
    var isIncoming: Bool
    var text: String
    
}

struct User {
    var email: String
    var fullname: String
    var profileImage: String
    var uid: String
    var username: String
}
