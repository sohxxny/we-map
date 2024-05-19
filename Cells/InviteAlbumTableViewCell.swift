//
//  InviteTableViewCell.swift
//  WeMap
//
//  Created by Lee Soheun on 5/2/24.
//

import UIKit

class InviteAlbumTableViewCell: UITableViewCell {
    
    @IBOutlet weak var inviteAlbumUserImage: UIImageView!
    @IBOutlet weak var inviteAlbumLocation: UILabel!
    @IBOutlet weak var inviteAlbumUserName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        inviteAlbumUserImage.layer.cornerRadius = inviteAlbumUserImage.frame.width / 2
        inviteAlbumUserImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
