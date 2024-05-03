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
    
    @IBOutlet weak var profileImage: UIButton!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var editNameButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이미지 둥글게
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        setCustomImageButton(button: editNameButton, color: .systemGray3, icon: "pencil-icon")
        
        // 백 버튼 설정 함수
        setBackButton(vc: self)
        
        // 이미지 피커 딜리게이트 설정
        self.imagePicker.delegate = self
        
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
        let actionSheet = UIAlertController(title: "프로필 사진 편집", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "사진 업로드", style: .default, handler: {_ in 
            self.accessPhotoLibrary()
        }))
        actionSheet.addAction(UIAlertAction(title: "기본 이미지로 변경", style: .default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // 앨범에서 사진을 선택하는 함수
    func accessPhotoLibrary() {
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.modalPresentationStyle = .currentContext
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let imageData = image.jpegData(compressionQuality: 0.75) {
            
            // 참조 작성
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child("profileImage/image.jpg")
            
            // 파일을 해당 경로로 업로드
            let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("에러 발생 : \(error)")
                } else {
                    print("image info : \(image)")
                }
            }
        }
        dismiss(animated: true, completion: nil)
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
