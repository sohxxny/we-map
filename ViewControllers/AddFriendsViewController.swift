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
    @IBOutlet weak var profilePhotoView: UIView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileEmail: UILabel!
    @IBOutlet weak var invalidFriendRequestLabel: UILabel!
    
    @IBOutlet weak var addFriendButton: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 임시
        getGesture()
        
        // 뷰 모서리 둥글게
        popUpBackgroundView.layer.cornerRadius = 15
        profilePhotoView.layer.cornerRadius = profilePhotoView.frame.width / 2

    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    @IBAction func tapSearchUser(_ sender: CustomButton) {
        guard let userEmail = searchUserTextField.text, !userEmail.isEmpty else { // 하나라도 비어 있다면 사용자에게 알리고 함수를 종료한다.
            AlertHelper.alertWithConfirmButton(on: self, with: nil, message: "검색할 이메일을 입력해주세요.")
            return }
        
        // 문서에서 해당 이메일 찾기
        Task {
            if let searchUid = await searchUserByEmail(email: userEmail, db: db) {
                // 프로필 다시 보이기
                hideProfile(value: false)
                let foundUser = await loadUserViewData(uid: searchUid, db: db)
                profileName.text = foundUser.userName
                profileEmail.text = foundUser.email
                
                // 만약 해당 유저가 내가 아니면 버튼 보이기
                if userEmail != userInfo.email {
                    addFriendButton.isHidden = false
                } else {
                    // 만약 해당 유저가 나일 경우 버튼 대신 라벨 보이기
                    invalidFriendRequestLabel.isHidden = false
                }
                
                
            } else {
                AlertHelper.alertWithConfirmButton(on: self, with: "검색 실패", message: "존재하지 않는 이메일입니다.")
            }
        }
    }
    
    @IBAction func tapAddFriend(_ sender: CustomButton) {
        print("친구 신청 버튼")
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
    
    // 임시 로그아웃 버튼
//    @IBAction func logOut(_ sender: UIButton) {
//        do {
//            try Auth.auth().signOut()
//            print("로그아웃 성공")
//        } catch let signOutError as NSError {
//            print("로그아웃 에러: ", signOutError)
//        }
//    }
    
}
