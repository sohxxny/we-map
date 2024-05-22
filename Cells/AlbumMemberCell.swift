//
//  AlbumMemberCell.swift
//  WeMap
//
//  Created by Lee Soheun on 5/22/24.
//

import UIKit

class AlbumMemberCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
    }
}
