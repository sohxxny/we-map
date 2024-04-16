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
    @IBOutlet weak var emailLoginTextField: CustomTextField!
    @IBOutlet weak var passwdLoginTextField: CustomTextField!
    @IBOutlet weak var signInButton: CustomButton!
    
    
    // firestore 관련 변수
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // firestore 인스턴스 초기화
        db = Firestore.firestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 리스너 연결
        // handle = Auth.auth().addStateDidChangeListener {
            
        }
    override func viewWillDisappear(_ animated: Bool) {
        // 리스너 분리
        // Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func tapSignInButton(_ sender: UIButton) {
        // 텍스트 필드가 비어있는지 확인
        guard let email = emailLoginTextField.text, !email.isEmpty,
              let passwd = passwdLoginTextField.text, !passwd.isEmpty else {
            // 하나라도 비어 있다면 사용자에게 알리고 함수를 종료한다.
            AlertHelper.alertWithConfirmButton(on: self, with: "로그인 실패", message: "모든 정보를 기입해주세요")
            return
        }
        
        // 로그인 함수 호출
        signIn(email: email, passwd: passwd)
        
    }
    
    // 로그인 함수
    func signIn(email: String, passwd: String) {
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
                
                // 해당 ID에 대한 userModel 생성
                Task {
                    var userInfo = await loadUserData(uid: authResult.user.uid, db: self!.db)
                    print(userInfo)
                }
            }
            
            // 로그인 성공 팝업 띄우기
            // AlertHelper.showAlertWithNoButton(on: strongSelf, with: "로그인 성공", message: "메인 화면으로 이동합니다.")
            
            // 메인 화면으로 이동하는 코드
            
            
        }
    }
    
    // 회원가입 화면에서 로그인 화면으로 돌아오기 위한 unwind segue
    @IBAction func unwindToSignIn(unwindSegue: UIStoryboardSegue) {
    }
    
    // 화면 터치 이벤트 함수
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        // 화면 터치 시 키보드 내리기
        self.view.endEditing(true)
    }
    
}
