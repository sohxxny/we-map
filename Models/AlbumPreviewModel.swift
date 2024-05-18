//
//  AlbumPreviewModel.swift
//  WeMap
//
//  Created by Lee Soheun on 5/18/24.
//

import Foundation
import UIKit

struct AlbumPreviewModel {
    var albumID: String
    var albumName: String
    var featuredImage: UIImage
    
    init(albumID: String, albumName: String, featuredImage: UIImage) {
        self.albumID = albumID
        self.albumName = albumName
        self.featuredImage = featuredImage
    }
}
