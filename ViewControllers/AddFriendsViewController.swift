//
//  AddFriendsViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 4/18/24.
//

import UIKit
import FirebaseAuth

class AddFriendsViewController: BaseViewController {
    
    @IBOutlet weak var searchUserTextField: CustomSearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func tapSearchUser(_ sender: CustomButton) {
        guard let userEmail = searchUserTextField.text, !userEmail.isEmpty else { // 하나라도 비어 있다면 사용자에게 알리고 함수를 종료한다.
            AlertHelper.alertWithConfirmButton(on: self, with: nil, message: "모든 정보를 기입해주세요")
            return }
        
        // 자기 자신의 이메일일 때
        
        
        // 문서에서 해당 이메일 찾기
        
        
        
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            print("로그아웃 성공")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
}
