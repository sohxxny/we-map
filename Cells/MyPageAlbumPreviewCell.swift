//
//  MyPageAlbumPreviewCell.swift
//  WeMap
//
//  Created by Lee Soheun on 5/24/24.
//

import UIKit

class MyPageAlbumPreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var featuredImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var noImageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        featuredImage.layer.cornerRadius = 5
    }
}
