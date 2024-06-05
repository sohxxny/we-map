//
//  MyFriendsPageViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 6/5/24.
//

import UIKit

class MyFriendsPageViewController: BaseViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var bookMarkButton: UIButton!
    
    var friendInfo: FriendsModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let profilePhoto = friendInfo.user.profilePhoto {
            setCustomImage(imageView: profileImage, image: profilePhoto)
        } else {
            setIconImage(imageView: profileImage, color: .weMapSkyBlue, icon: "user-icon")
        }
        profileName.text = friendInfo.user.userName
        self.setBooMarkIcon(button: bookMarkButton, isBookMarked: friendInfo.isBookMarked)
    }
    
    func setBooMarkIcon(button: UIButton, isBookMarked: Bool) {
        let newImage = isBookMarked ? UIImage(systemName: "star.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal) : UIImage(systemName: "star")?.withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
        button.setImage(newImage, for: .normal)
    }
    
    @IBAction func tapBookMarkButton(_ sender: UIButton) {
        Task {
            await setBookMarkStatus(status: friendInfo.isBookMarked ? false : true)
        }
    }
    
    func setBookMarkStatus(status: Bool) async {
        guard let userInfo = GlobalUserManager.shared.globalUser else { return }
        await changeBookMarkStatus(set: status, friendInfo.user.email, in: userInfo)
        friendInfo.isBookMarked = status
        setBooMarkIcon(button: bookMarkButton, isBookMarked: status)
        AlertHelper.showAlertWithNoButton(on: self, with: nil, message: "친구 즐겨찾기가 \(status ? "완료" : "취소")되었습니다.")
    }
}
