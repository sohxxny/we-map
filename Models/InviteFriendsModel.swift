//
//  InviteFriendsModel.swift
//  WeMap
//
//  Created by Lee Soheun on 5/19/24.
//

import Foundation

struct InviteFriendsModel {
    var UserViewModel: UserViewModel
    var isSelected: Bool
    
    init(UserViewModel: UserViewModel, isSelected: Bool) {
        self.UserViewModel = UserViewModel
        self.isSelected = isSelected
    }
}
