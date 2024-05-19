//
//  ProfileTableViewCell.swift
//  WeMap
//
//  Created by Lee Soheun on 4/7/24.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 이미지 뷰를 원형으로 만들기
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
