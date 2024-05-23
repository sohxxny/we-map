//
//  PhotoViewModel.swift
//  WeMap
//
//  Created by Lee Soheun on 5/24/24.
//

import Foundation
import UIKit
import FirebaseFirestore

struct PhotoViewModel {
    var image: UIImage
    var photoRef: DocumentReference
    var timeStamp: Timestamp
    var comments: [CommentModel]
    
    init(image: UIImage, photoRef: DocumentReference, timeStamp: Timestamp, comments: [CommentModel] = []) {
        self.image = image
        self.photoRef = photoRef
        self.timeStamp = timeStamp
        self.comments = comments
    }
}
