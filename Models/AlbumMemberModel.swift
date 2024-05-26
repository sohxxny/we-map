//
//  AlbumMemberModel.swift
//  WeMap
//
//  Created by Lee Soheun on 5/26/24.
//

import Foundation

struct AlbumMemberModel {
    var user: UserViewModel
    var isJoined: Bool
    
    init(user: UserViewModel, isJoined: Bool) {
        self.user = user
        self.isJoined = isJoined
    }
}
