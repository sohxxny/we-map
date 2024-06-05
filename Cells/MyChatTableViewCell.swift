//
//  MyChatTableViewCell.swift
//  WeMap
//
//  Created by Lee Soheun on 5/30/24.
//

import UIKit

class MyChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var chatContent: UILabel!
    @IBOutlet weak var chatTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        chatView.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
