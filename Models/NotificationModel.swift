//
//  NotificationModel.swift
//  WeMap
//
//  Created by Lee Soheun on 5/3/24.
//

import Foundation
import UIKit

struct NotificationModel {
    var type: NotificationType
    var userName: String
    var userEmail: String
    var userImage : UIImage?
    var location: String?
    
    init(type: NotificationType, userName: String, userEmail: String, userImage: UIImage?, location: String? = nil) {
        self.type = type
        self.userName = userName
        self.userEmail = userEmail
        self.userImage = userImage
        self.location = location
    }
}

enum NotificationType {
    case friendsRequest
    case inviteAlbum
}
