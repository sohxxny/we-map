//
//  NotificationModel.swift
//  WeMap
//
//  Created by Lee Soheun on 5/3/24.
//

import Foundation
import UIKit
import FirebaseFirestore

struct NotificationModel {
    var type: NotificationType
    var userName: String
    var userEmail: String
    var userImage : UIImage?
    var location: String?
    var notificationRef: DocumentReference
    var albumRef: DocumentReference?
    
    init(type: NotificationType, userName: String, userEmail: String, userImage: UIImage?, location: String? = nil, notificationRef: DocumentReference, albumRef: DocumentReference? = nil) {
        self.type = type
        self.userName = userName
        self.userEmail = userEmail
        self.userImage = userImage
        self.location = location
        self.notificationRef = notificationRef
        self.albumRef = albumRef
    }
}

enum NotificationType {
    case friendsRequest
    case inviteAlbum
}
