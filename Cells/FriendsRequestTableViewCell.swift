//
//  FriendsRequestTableViewCell.swift
//  WeMap
//
//  Created by Lee Soheun on 5/1/24.
//

import UIKit

class FriendsRequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendsRequestUserImage: UIImageView!
    @IBOutlet weak var friendsRequestUserName: UILabel!
    @IBOutlet weak var friendsRequestAcceptButton: CustomFilledButton!
    @IBOutlet weak var friendsRequestRejectButton: CustomPlainButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 이미지 뷰를 원형으로 만들기
        friendsRequestUserImage.layer.cornerRadius = friendsRequestUserImage.frame.width / 2
        friendsRequestUserImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
