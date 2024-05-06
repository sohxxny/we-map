//
//  EditProfileViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/6/24.
//

import UIKit
import FirebaseStorage

class EditProfileViewController: BaseViewController {
    
    @IBOutlet weak var editProfileImageButton: UIButton!
    @IBOutlet weak var editName: CustomTextField!
    @IBOutlet weak var editProfileMessage: CustomTextField!
    @IBOutlet weak var profileNameLength: UILabel!
    @IBOutlet weak var profileMessageLength: UILabel!
    @IBOutlet weak var editCompleteButton: CustomFilledButton!
    
    let profileImagePicker = UIImagePickerController()
    let maxNameLength = 20
    let maxProfileMessageLength = 40

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이미지 모서리 둥글게
        editProfileImageButton.layer.cornerRadius = editProfileImageButton.frame.width / 2
        
        // 텍스트 필드 및 라벨 초기 설정
        if let myViewModel = GlobalFriendsManager.shared.globalMyViewModel {
            
            editName.clearButtonMode = .whileEditing
            editProfileMessage.clearButtonMode = .whileEditing
            
            editName.placeholder = myViewModel.userName
            editName.text = myViewModel.userName
            editProfileMessage.text = myViewModel.profileMessage
            
            profileNameLength.text = "\(myViewModel.userName.count) / 20"
            profileMessageLength.text = "\(myViewModel.profileMessage.count) / 40"
        }
        
        // 초기에는 버튼 disabled
        editCompleteButton.isEnabled = false
        
        // 텍스트 필드 입력 감지
        editName.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        editProfileMessage.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let myViewModel = GlobalFriendsManager.shared.globalMyViewModel {
            
            // 프로필 이미지 불러오기
            if let profilePhoto = myViewModel.profilePhoto {
                setCustomImageButton(button: editProfileImageButton, image: profilePhoto)
            } else {
                setIconImageButton(button: editProfileImageButton, color: .weMapSkyBlue, icon: "user-icon")
            }
        }
    }
    
    // 텍스트 필드 내용이 바뀔 때마다 호출
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let name = editName.text, let message = editProfileMessage.text, let myViewModel = GlobalFriendsManager.shared.globalMyViewModel else { return }
        
        profileNameLength.text = "\(name.count) / 20"
        profileMessageLength.text = "\(message.count) / 40"
        
        if name != myViewModel.userName || message != myViewModel.profileMessage {
            editCompleteButton.isEnabled = true
        } else {
            editCompleteButton.isEnabled = false
        }
    }

    // 프로필 이미지 변경
    @IBAction func tapEditProfileImage(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "프로필 사진 편집", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "사진 업로드", style: .default, handler: {_ in
            self.openPhotoLibrary()
        }))
        if GlobalFriendsManager.shared.globalMyViewModel?.profilePhoto != nil {
            actionSheet.addAction(UIAlertAction(title: "기본 이미지로 변경", style: .default, handler: {_ in
                self.changeToDefaultImage()
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "닫기", style: .cancel))
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
                setIconImageButton(button: editProfileImageButton, color: .weMapSkyBlue, icon: "user-icon")
            }
        }
    }
    
    @IBAction func tapEditComplete(_ sender: CustomFilledButton) {
        
    }
    

}
