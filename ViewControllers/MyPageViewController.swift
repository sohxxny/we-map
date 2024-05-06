//
//  MyPageViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 4/28/24.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class MyPageViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileMessage: UILabel!
    
    let profileImagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이미지 둥글게
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        
        // 백 버튼 설정 함수
        setBackButton(vc: self)
        
        // 이미지 피커 딜리게이트 설정
        self.profileImagePicker.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let myViewModel = GlobalFriendsManager.shared.globalMyViewModel {
            
            // 프로필 이미지 불러오기
            if let profilePhoto = myViewModel.profilePhoto {
                setCustomImage(imageView: profileImage, image: profilePhoto)
            } else {
                setIconImage(imageView: profileImage, color: .weMapSkyBlue, icon: "user-icon")
            }
            
            // 프로필 이름 불러오기
            profileName.text = myViewModel.userName
            profileMessage.text = myViewModel.profileMessage
        }
        
    }
    
}
