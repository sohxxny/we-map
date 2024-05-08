//
//  EditProfileViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/6/24.
//

import UIKit
import FirebaseStorage

class EditProfileViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var editProfileImageButton: UIButton!
    @IBOutlet weak var editName: CustomTextField!
    @IBOutlet weak var editProfileMessage: CustomTextField!
    @IBOutlet weak var profileNameLength: UILabel!
    @IBOutlet weak var profileMessageLength: UILabel!
    @IBOutlet weak var editCompleteButton: CustomFilledButton!
    @IBOutlet weak var invalidNameWarning: UILabel!
    
    let profileImagePicker = UIImagePickerController()
    
    var originalImage: UIImage?
    var isImagePickerActive = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이미지 모서리 둥글게
        editProfileImageButton.layer.cornerRadius = editProfileImageButton.frame.width / 2
        
        // 텍스트 필드 및 라벨 초기 설정
        if let myViewModel = GlobalFriendsManager.shared.globalMyViewModel {
            
            originalImage = myViewModel.profilePhoto
            
            editName.clearButtonMode = .whileEditing
            editProfileMessage.clearButtonMode = .whileEditing
            
            editName.placeholder = myViewModel.userName
            editName.text = myViewModel.userName
            editProfileMessage.text = myViewModel.profileMessage
            
            profileNameLength.text = "\(myViewModel.userName.count) / \(maxNameLength)"
            profileMessageLength.text = "\(myViewModel.profileMessage.count) / \(maxProfileMessageLength)"
        }
        
        // ImagePicker 딜리게이트 설정
        self.profileImagePicker.delegate = self
        
        // 초기에는 버튼 disabled
        setButtonOn(button: editCompleteButton, isOn: false)
        
        // 초기에는 경고문구 hidden
        invalidNameWarning.isHidden = true
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        GlobalFriendsManager.shared.globalMyViewModel?.profilePhoto = originalImage
    }
    
    // 텍스트 필드 내용이 바뀔 때마다 호출
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let name = editName.text, let message = editProfileMessage.text, let myViewModel = GlobalFriendsManager.shared.globalMyViewModel else { return }
        
        // 텍스트 길이 보이기
        profileNameLength.text = (name.count > maxNameLength ? "\(maxNameLength)" : "\(name.count)") +  " / \(maxNameLength)"
        profileMessageLength.text = (message.count > maxProfileMessageLength ? "\(maxProfileMessageLength)" : "\(message.count)") +  " / \(maxProfileMessageLength)"
        
        // 이름이 공백으로만 이루어져 있을 경우 경고 문구 띄우기
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            invalidNameWarning.isHidden = false
        } else {
            invalidNameWarning.isHidden = true
        }
        
        // 변경사항이 있을 때만 완료 버튼 enable하게 만들기
        if !invalidNameWarning.isHidden {
            setButtonOn(button: editCompleteButton, isOn: false)
        } else {
            if name != myViewModel.userName || message != myViewModel.profileMessage {
                setButtonOn(button: editCompleteButton, isOn: true)
            } else {
                setButtonOn(button: editCompleteButton, isOn: false)
            }
        }
        
        // 일정 글자수 이상으로 입력되면 삭제
        if name.count > maxNameLength {
            editName.text = String(name.prefix(maxNameLength))
        }
        if message.count > maxProfileMessageLength {
            editProfileMessage.text = String(message.prefix(maxProfileMessageLength))
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
        if picker === profileImagePicker {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                
                // 현재 이미지에 적용
                GlobalFriendsManager.shared.globalMyViewModel?.profilePhoto = image
                if image != originalImage {
                    setButtonOn(button: editCompleteButton, isOn: true)
                } else {
                    setButtonOn(button: editCompleteButton, isOn: false)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 프로필을 기본 이미지로 변경
    func changeToDefaultImage() {
        Task {
            if GlobalUserManager.shared.globalUser != nil {
                // 유저 프로필 정보 업데이트
                GlobalFriendsManager.shared.globalMyViewModel?.profilePhoto = nil
                setIconImageButton(button: editProfileImageButton, color: .weMapSkyBlue, icon: "user-icon")
                
                // 원래 기본이미지가 아니었다면 완료 버튼 active
                if originalImage != nil {
                    setButtonOn(button: editCompleteButton, isOn: true)
                } else {
                    setButtonOn(button: editCompleteButton, isOn: false)
                }
            }
        }
    }
    
    // 완료 버튼 탭
    @IBAction func tapEditComplete(_ sender: CustomFilledButton) {
        AlertHelper.alertWithTwoButton(on: self, with: nil, message: "변경 사항을 저장하시겠습니까?", completion: {
            // 저장 전까지 로딩 버튼 띄우기
            self.editProfile()
            // 로딩 버튼 끄기
            
            // 변경 완료
        })
    }
    
    func editProfile() {
        guard let name = editName.text, let message = editProfileMessage.text, let myViewModel = GlobalFriendsManager.shared.globalMyViewModel, let userInfo = GlobalUserManager.shared.globalUser else {
            return
        }
        Task {
            // 이미지 저장 (빠른 로딩을 위해 변경되었을 때만 실행)
            let profileImageName: String = userInfo.email.replacingOccurrences(of: "[@.]", with: "_", options: .regularExpression)
            if myViewModel.profilePhoto != originalImage {
                // 이미지를 기본 이미지로 변경했을 경우
                if myViewModel.profilePhoto == nil {
                    // 파이어베이스 데이터베이스의 프로필 사진 삭제 및 이미지 경로 공백으로 변경
                    await deleteImage(path: "profileImage/\(profileImageName).jpg")
                    await GlobalUserManager.shared.setProfileImagePath(path: "")
                    
                // 이미지를 설정했을 경우
                } else {
                    // 프로필 사진 이름을 유저 이메일로 설정 및 유저 프로필 정보 업데이트
                    await GlobalUserManager.shared.setProfileImagePath(path: profileImageName)
                    
                    // 파일을 해당 경로로 업로드
                    if let imageData = myViewModel.profilePhoto!.jpegData(compressionQuality: 0.75) {
                        let storageRef = Storage.storage().reference()
                        let imageRef = storageRef.child("profileImage/\(profileImageName).jpg")
                        imageRef.putData(imageData, metadata: nil) { metadata, error in
                            if let error = error {
                                print("에러 발생 : \(error)")
                            } else {
                                print("image info : \(String(describing: myViewModel.profilePhoto))")
                            }
                        }
                    }
                }
            }
            
            // 이름 수정
            let editedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            await GlobalUserManager.shared.setProfileName(newName: editedName)
            await GlobalUserManager.shared.setProfileMessage(newMessage: message)
            
            // alert 띄우기 및 viewModel에 저장
            GlobalUserManager.shared.globalUser?.userName = editedName
            GlobalFriendsManager.shared.updateMyViewModel(name: editedName, message: message)
            AlertHelper.showAlertWithNoButton(on: self, with: nil, message: "프로필 수정이 완료되었습니다.")
            
            editName.text = editedName
            originalImage = GlobalFriendsManager.shared.globalMyViewModel?.profilePhoto
            setButtonOn(button: editCompleteButton, isOn: false)
        }
    }
    
    // 버튼 enabled 설정을 바꾸는 함수
    func setButtonOn(button: UIButton, isOn: Bool) {
        if isOn {
            button.isEnabled = true
            button.alpha = 1.0
        } else {
            button.isEnabled = false
            button.alpha = 0.5
        }
    }
}
