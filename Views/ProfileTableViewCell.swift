//
//  ProfileTableViewCell.swift
//  WeMap
//
//  Created by Lee Soheun on 4/7/24.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    // firestore 관련 변수
    var db: Firestore!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // firestore 인스턴스 초기화
        db = Firestore.firestore()
        
        // 이미지 뷰를 원형으로 만들기
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
