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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
