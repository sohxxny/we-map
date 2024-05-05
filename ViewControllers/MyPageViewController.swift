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
                setCustomImageButton(button: profileImage, image: profilePhoto)
            } else {
                setIconImageButton(button: profileImage, color: .weMapSkyBlue, icon: "user-icon")
            }
            
            // 프로필 이름 불러오기
            profileName.text = myViewModel.userName
            profileMessage.text = myViewModel.profileMessage
        }
        
        
    }
    
    // 프로필 이미지 변경 버튼 클릭 이벤트 함수
    @IBAction func changeProfileImage(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "프로필 사진 편집", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "사진 업로드", style: .default, handler: {_ in 
            self.openPhotoLibrary()
        }))
        if GlobalFriendsManager.shared.globalMyViewModel?.profilePhoto != nil {
            actionSheet.addAction(UIAlertAction(title: "기본 이미지로 변경", style: .default, handler: {_ in
                self.changeToDefaultImage()
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // 앨범에서 사진을 선택하는 함수
    func openPhotoLibrary() {
        self.profileImagePicker.sourceType = .photoLibrary
        self.profileImagePicker.modalPresentationStyle = .currentContext
        self.present(self.profileImagePicker, animated: true, completion: nil)
    }
    
    // 이미지 picker 컨트롤러
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        Task {
            if picker === profileImagePicker {
                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let imageData = image.jpegData(compressionQuality: 0.75), let userInfo = GlobalUserManager.shared.globalUser {
                    
                    // 프로필 사진 이름을 유저 이메일로 설정 및 유저 프로필 정보 업데이트
                    let profileImageName: String = userInfo.email.replacingOccurrences(of: "[@.]", with: "_", options: .regularExpression)
                    await GlobalUserManager.shared.setProfileImagePath(path: profileImageName)
                    
                    // 빠른 동기화를 위해 데이터베이스에서 불러오지 않고 바로 viewModel에 적용
                    GlobalFriendsManager.shared.globalMyViewModel?.profilePhoto = image
                    
                    // 파일을 해당 경로로 업로드
                    let storageRef = Storage.storage().reference()
                    let imageRef = storageRef.child("profileImage/\(profileImageName).jpg")
                    imageRef.putData(imageData, metadata: nil) { metadata, error in
                        if let error = error {
                            print("에러 발생 : \(error)")
                        } else {
                            print("image info : \(image)")
                        }
                    }
                }
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    // 프로필을 기본 이미지로 변경
    func changeToDefaultImage() {
        Task {
            if let userInfo = GlobalUserManager.shared.globalUser {
                
                // 파이어베이스 데이터베이스의 프로필 사진 삭제
                let profileImageName: String = userInfo.email.replacingOccurrences(of: "[@.]", with: "_", options: .regularExpression)
                await deleteImage(path: "profileImage/\(profileImageName).jpg")
                
                // 파이어베이스 프로필 이미지 경로 공백으로 변경
                await GlobalUserManager.shared.setProfileImagePath(path: "")
                
                // 유저 프로필 정보 업데이트 (빠른 동기화를 위해 데이터베이스에서 불러오지 않고 바로 적용)
                GlobalFriendsManager.shared.globalMyViewModel?.profilePhoto = nil
                setIconImageButton(button: profileImage, color: .weMapSkyBlue, icon: "user-icon")
            }
        }
    }
    
}
