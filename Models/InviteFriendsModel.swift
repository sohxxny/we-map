//
//  InviteFriendsModel.swift
//  WeMap
//
//  Created by Lee Soheun on 6/5/24.
//

import Foundation

class InviteFriendsModel {
    var user: FriendsModel
    var isSelected: Bool
    
    init(user: FriendsModel, isSelected: Bool) {
        self.user = user
        self.isSelected = isSelected
    }
}

func createInviteFriendsList(userInfoList: [FriendsModel]) -> [InviteFriendsModel] {
    var inviteFriendsList: [InviteFriendsModel] = []
    for userInfo in userInfoList {
        inviteFriendsList.append(InviteFriendsModel(user: userInfo, isSelected: false))
    }
    return inviteFriendsList
}
