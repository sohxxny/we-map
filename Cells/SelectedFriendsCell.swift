//
//  SelectedFriendsCell.swift
//  WeMap
//
//  Created by Lee Soheun on 5/20/24.
//

import UIKit

class SelectedFriendsCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var deleteImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        deleteImage.layer.cornerRadius = deleteImage.frame.width / 2
    }
}
