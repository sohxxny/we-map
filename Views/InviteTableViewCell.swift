//
//  InviteTableViewCell.swift
//  WeMap
//
//  Created by Lee Soheun on 5/2/24.
//

import UIKit

class InviteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var inviteUserImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        inviteUserImage.layer.cornerRadius = inviteUserImage.frame.width / 2
        inviteUserImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
