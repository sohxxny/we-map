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
    @IBOutlet weak var selectButton: UIButton!
    
    var isButtonSelected: Bool!
    var buttonSelected: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        
        setButtonIcon(button: selectButton, select: false)
        isButtonSelected = false
        
        selectButton.addTarget(self, action: #selector(tapSelectButton), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // 버튼 터치 시 작동하는 함수
    @objc func tapSelectButton() {
        buttonSelected?()
    }
    
    func setButtonIcon(button: UIButton, select: Bool) {
        if select {
            let newImage = UIImage(systemName: "checkmark.square.fill")?.withTintColor(.weMapBlue, renderingMode: .alwaysOriginal)
            selectButton.setImage(newImage, for: .normal)
        } else {
            let newImage = UIImage(systemName: "square")?.withTintColor(.systemGray4, renderingMode: .alwaysOriginal)
            selectButton.setImage(newImage, for: .normal)
        }
    }
    

}
