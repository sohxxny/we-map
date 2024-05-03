//
//  NotificationModel.swift
//  WeMap
//
//  Created by Lee Soheun on 5/3/24.
//

import Foundation

struct NotificationModel {
    var type: NotificationType
    var userName: String
    var userEmail: String
    var location: String?
    
    init(type: NotificationType, userName: String, userEmail: String, location: String? = nil) {
        self.type = type
        self.userName = userName
        self.userEmail = userEmail
        self.location = location
    }
}

enum NotificationType {
    case friendsRequest
    case inviteAlbum
}
