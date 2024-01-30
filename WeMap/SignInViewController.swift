//
//  SignInViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 2024/01/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class SignInViewController: UIViewController {
    @IBOutlet weak var emialLoginTextField: UITextField!
    @IBOutlet weak var passwdLoginTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 리스너 연결
        // handle = Auth.auth().addStateDidChangeListener {
            
        }
    override func viewWillDisappear(_ animated: Bool) {
        // 리스너 분리
        // Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func SignInButtonTapped(_ sender: UIButton) {
        // 텍스트 필드가 비어있는지 확인
        guard let email = emialLoginTextField.text, !email.isEmpty,
              let passwd = emialLoginTextField.text, !passwd.isEmpty else {
            // 하나라도 비어 있다면 사용자에게 알리고 함수를 종료한다.
            print("모든 정보를 기입해주세요.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: passwd) { [weak self] authResult, error in
          guard let strongSelf = self else { return }

            // 로그인 실패 시 에러 메시지 출력 및 함수 탈출
            if let error = error {
                print("로그인 실패: \(error.localizedDescription)")
                return
            }

            // 로그인 성공시 ID 띄우기
            if let authResult = authResult {
                print("로그인 성공: 사용자 ID - \(authResult.user.uid)")
            }
        }
        
        // 로그인 성공 팝업 띄우기
        AlertHelper.showAlertWithNoButton(on: self, with: "로그인 성공", message: "메인 화면으로 이동합니다.")
    }
    
    
}
