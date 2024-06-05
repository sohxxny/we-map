//
//  FriendsModel.swift
//  WeMap
//
//  Created by Lee Soheun on 6/4/24.
//

import Foundation
import FirebaseFirestore

class FriendsModel {
    var user: UserViewModel
    var isBookMarked: Bool
    
    init(user: UserViewModel, isBookMarked: Bool) {
        self.user = user
        self.isBookMarked = isBookMarked
    }
}
