//
//  AddFriendsViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 4/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AddFriendsViewController: BaseViewController {
    
    @IBOutlet weak var searchUserTextField: CustomSearchBar!
    @IBOutlet weak var popUpBackgroundView: UIView!
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileEmail: UILabel!
    @IBOutlet weak var invalidFriendRequestLabel: UILabel!
    @IBOutlet weak var addFriendButton: CustomFilledButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 임시
        getGesture()
        
        // 뷰 모서리 둥글게
        popUpBackgroundView.layer.cornerRadius = 15
        profilePhotoView.layer.cornerRadius = profilePhotoView.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // 처음 로드 시 뷰 숨기기
        hideProfile(value: true)
        addFriendButton.isHidden = true
        invalidFriendRequestLabel.isHidden = true
    }
    
    // 다른 화면으로 이동할 경우 이 팝업 닫기
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // 화면 터치 핸들 함수 (팝업 뷰가 아닌 곳을 터치하면 팝업 내리기)
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let touchView = sender.location(in: self.view)
        if popUpBackgroundView.frame.contains(touchView) {
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // 제스처 입력 받기
    func getGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func tapSearchUser(_ sender: CustomFilledButton) {
        guard let userEmail = searchUserTextField.text, !userEmail.isEmpty else { // 하나라도 비어 있다면 사용자에게 알리고 함수를 종료한다.
            AlertHelper.alertWithConfirmButton(on: self, with: nil, message: "검색할 이메일을 입력해주세요.")
            return }
        
        // 문서에서 해당 이메일 찾기
        Task {
            if (await searchUserByEmail(email: userEmail)) != nil {
                // 프로필 다시 보이기
                hideProfile(value: false)
                if let foundUser = await UserViewModel.createUserViewModel(email: userEmail) {
                    // 프로필 사진 지정
                    if let userProfilePhoto = foundUser.profilePhoto {
                        setCustomImage(imageView: profilePhotoView, image: userProfilePhoto)
                    } else {
                        setIconImage(imageView: profilePhotoView, color: .weMapSkyBlue, icon: "user-icon")
                    }
                    profileName.text = foundUser.userName
                    profileEmail.text = foundUser.email
                    
                    if let userInfo = GlobalUserManager.shared.globalUser {
                        // 해당 유저가 나일 경우
                        if userEmail == userInfo.email {
                            addFriendButton.isHidden = true
                            invalidFriendRequestLabel.text = "자신에게 친구 요청을 보낼 수 없습니다."
                            invalidFriendRequestLabel.isHidden = false
                        // 해당 유저가 내가 아닐 경우
                        } else {
                            addFriendButton.isHidden = true
                            invalidFriendRequestLabel.isHidden = true
                            if let isMyFriends = await GlobalUserManager.shared.isFriends(userEmail: userEmail) {
                                // 만약 이미 친구인 유저일 경우
                                if isMyFriends {
                                    invalidFriendRequestLabel.text = "이미 친구인 사용자입니다."
                                    invalidFriendRequestLabel.isHidden = false
                                // 친구가 아닐 경우
                                } else {
                                    if let isRequesting = await GlobalUserManager.shared.isFriendsRequesting(senderEmail: userInfo.email, receiverEmail: userEmail) {
                                        // 친구 신청 중일 경우
                                        if isRequesting {
                                            addFriendButton.setTitle("친구 요청 취소", for: .normal)
                                            addFriendButton.isHidden = false
                                        } else {
                                            addFriendButton.setTitle("친구 요청", for: .normal)
                                            addFriendButton.isHidden = false
                                        }
                                    }
                                }
                            } else {
                                print("오류")
                            }
                        }
                    }
                }
            // 해당 이메일이 존재하지 않을 경우
            } else {
                AlertHelper.alertWithConfirmButton(on: self, with: "검색 실패", message: "존재하지 않는 이메일입니다.")
            }
        }
    }
    
    @IBAction func tapAddFriend(_ sender: CustomFilledButton) {
        let db = Firestore.firestore()
        guard let buttonType = addFriendButton.titleLabel?.text else { return }
        Task {
            if let profileEmail = profileEmail.text, let userInfo = GlobalUserManager.shared.globalUser, let userUid = await searchUserByEmail(email: profileEmail) {
                // 상대방과 문서에 이메일 저장
                if buttonType == "친구 요청" {
                    if let isRequested = await GlobalUserManager.shared.isFriendsRequesting(senderEmail: profileEmail, receiverEmail: userInfo.email) {
                        if isRequested {
                            AlertHelper.alertWithConfirmButton(on: self, with: nil, message: "상대방이 이미 친구 요청 응답을 기다리는 중입니다.")
                        } else {
                            try await db.collection("userInfo").document(userUid).collection("notification").addDocument(data: [
                                "type": "friendsRequest",
                                "userEmail": userInfo.email
                            ])
                            AlertHelper.showAlertWithNoButton(on: self, with: nil, message: "친구 요청이 완료되었습니다.")
                            addFriendButton.setTitle("친구 요청 취소", for: .normal)
                        }
                    }
                } else {
                    // 친구 요청 삭제하기
                    await GlobalUserManager.shared.deleteFriendsRequest(senderEmail: userInfo.email, receiverEmail: profileEmail, receiverUid: userUid)
                    AlertHelper.showAlertWithNoButton(on: self, with: nil, message: "친구 요청이 취소되었습니다.")
                    addFriendButton.setTitle("친구 요청", for: .normal)
                }
            }
        }
    }
    
    // X 버튼 누르면 팝업 닫기
    @IBAction func tapBackToFriendsList(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 프로필 컴포넌트 보이기
    func hideProfile(value: Bool) {
        profilePhotoView.isHidden = value
        profileName.isHidden = value
        profileEmail.isHidden = value
    }
}
