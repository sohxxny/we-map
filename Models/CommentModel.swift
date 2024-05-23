//
//  CommentModel.swift
//  WeMap
//
//  Created by Lee Soheun on 5/24/24.
//

import Foundation
import FirebaseFirestore

struct CommentModel {
    var user: UserViewModel
    var content: String
    var commentRef: DocumentReference
    var timeStamp: Timestamp

    init(user: UserViewModel, content: String, commentRef: DocumentReference, timeStamp: Timestamp) {
        self.user = user
        self.content = content
        self.commentRef = commentRef
        self.timeStamp = timeStamp
    }
}
