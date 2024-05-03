//
//  MyPageViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 4/28/24.
//

import UIKit
import FirebaseAuth

class MyPageViewController: BaseViewController {
    
    @IBOutlet weak var profileImage: UIButton!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var editNameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이미지 둥글게
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        setCustomImageButton(button: editNameButton, color: .systemGray3, icon: "pencil-icon")
        
        // 백 버튼 설정 함수
        setBackButton(vc: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let myInfo = GlobalFriendsManager.shared.globalMyViewModel
        
        // 프로필 이미지 불러오기
        if myInfo?.profileMessage == "" {
            setCustomImageButton(button: profileImage, color: .weMapSkyBlue, icon: "user-icon")
        } else {
            
        }
        
        // 프로필 이름 불러오기
        profileName.text = myInfo?.userName
    }
    
    // 프로필 이미지 변경 버튼 클릭 이벤트 함수
    @IBAction func changeProfileImage(_ sender: UIButton) {
        UIAlertController(title: "프로필 사진 편집", message: "원하는 @@을 선택해주세요.", preferredStyle: .actionSheet)
    }
    
    // 로그아웃 버튼
    @IBAction func logOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            print("로그아웃 성공")
            GlobalUserManager.shared.globalUser = nil
            GlobalFriendsManager.shared.globalMyViewModel = nil
            GlobalFriendsManager.shared.globalFriendsList = []
            
            // 미리 홈 화면으로 이동
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let homeViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
                sceneDelegate.window?.rootViewController = homeViewController
                
                // 모든 모달 제거
            }
            
        } catch let signOutError as NSError {
            print("로그아웃 에러: ", signOutError)
        }
    }
    
}
