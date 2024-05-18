//
//  LocationDetailsAlbumCell.swift
//  WeMap
//
//  Created by Lee Soheun on 5/18/24.
//

import UIKit

class LocationDetailsAlbumCell: UICollectionViewCell {
    
    @IBOutlet weak var featuredImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // featuredImage.layer.cornerRadius = 5
    }
}
