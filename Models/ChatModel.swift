//
//  ChatModel.swift
//  WeMap
//
//  Created by Lee Soheun on 6/1/24.
//

import Foundation
import FirebaseDatabase

struct ChatModel {
    var user: UserViewModel
    var content: String
    var timeStatmp: Int64
    
    init(user: UserViewModel, content: String, timeStatmp: Int64) {
        self.user = user
        self.content = content
        self.timeStatmp = timeStatmp
    }
}
