//
//  InviteFriendsCell.swift
//  WeMap
//
//  Created by Lee Soheun on 5/18/24.
//

import UIKit

class InviteFriendsCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var checkBox: UIImageView!
    
    
    var buttonSelected: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        setCheckBoxIcon(imageView: checkBox, select: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setCheckBoxIcon(imageView: UIImageView, select: Bool) {
        if select {
            let newImage = UIImage(systemName: "checkmark.square.fill")?.withTintColor(.weMapBlue, renderingMode: .alwaysOriginal)
            imageView.image = newImage
        } else {
            let newImage = UIImage(systemName: "square")?.withTintColor(.systemGray4, renderingMode: .alwaysOriginal)
            imageView.image = newImage
        }
    }
}
