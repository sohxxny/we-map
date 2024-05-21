//
//  AlbumPreviewModel.swift
//  WeMap
//
//  Created by Lee Soheun on 5/18/24.
//

import Foundation
import UIKit
import FirebaseFirestore

struct AlbumPreviewModel {
    var albumRef: DocumentReference
    var albumName: String
    var timeStamp: Timestamp
    var featuredImage: UIImage?
    
    init(albumRef: DocumentReference, albumName: String, timeStamp: Timestamp, featuredImage: UIImage?) {
        self.albumRef = albumRef
        self.albumName = albumName
        self.timeStamp = timeStamp
        self.featuredImage = featuredImage
    }
}
