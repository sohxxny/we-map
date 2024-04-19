//
//  AddFriendsViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 4/18/24.
//

import UIKit
import FirebaseAuth

class AddFriendsViewController: BaseViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var searchUserTextField: CustomSearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 임시
        getGesture()

    }
    
    // 화면 터치 핸들 함수 (팝업이 떠 있는 경우 내리기)
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("친구신청 화면 터치")
    }
    
    // 제스처 입력 받기
    func getGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 화면 설정
        setScreen()
    }
    
    @IBAction func tapSearchUser(_ sender: CustomButton) {
        guard let userEmail = searchUserTextField.text, !userEmail.isEmpty else { // 하나라도 비어 있다면 사용자에게 알리고 함수를 종료한다.
            AlertHelper.alertWithConfirmButton(on: self, with: nil, message: "검색할 이메일을 입력해주세요.")
            return }
        
        // 자기 자신의 이메일일 때
        
        
        // 문서에서 해당 이메일 찾기
        
        
        
    }
    
    // 화면 크기 설정 함수
    func setScreen() {
        let screenSize = UIScreen.main.bounds.size
        let popupWidth: CGFloat = 350
        let popupHeight: CGFloat = 500

        self.view.frame = CGRect(x: (screenSize.width - popupWidth) / 2,
                                 y: (screenSize.height - popupHeight) / 2,
                                 width: popupWidth,
                                 height: popupHeight)
        self.view.backgroundColor = .white
        self.view.layer.cornerRadius = 15
    }
    
    // 임시 로그아웃 버튼
    @IBAction func logOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            print("로그아웃 성공")
        } catch let signOutError as NSError {
            print("Error signing out: ", signOutError)
        }
    }
    
}
