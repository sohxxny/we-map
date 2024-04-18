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

class SignInViewController: BaseViewController {
    
    @IBOutlet weak var emailLoginTextField: CustomTextField!
    @IBOutlet weak var passwdLoginTextField: CustomTextField!
    @IBOutlet weak var signInButton: CustomButton!
    
    var db: Firestore!
    // var userInfo: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // firestore 인스턴스 초기화
        db = Firestore.firestore()
    }
    
    @IBAction func tapSignInButton(_ sender: UIButton) {
        // 텍스트 필드가 비어있는지 확인
        guard let email = emailLoginTextField.text, !email.isEmpty,
              let passwd = passwdLoginTextField.text, !passwd.isEmpty else {
            // 하나라도 비어 있다면 사용자에게 알리고 함수를 종료한다.
            AlertHelper.alertWithConfirmButton(on: self, with: nil, message: "모든 정보를 기입해주세요")
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
            if let error = error as NSError? {
                if error.domain == AuthErrorDomain {
                    switch (error.code) {
                    case AuthErrorCode.invalidEmail.rawValue:
                        AlertHelper.alertWithConfirmButton(on: self!, with: "로그인 실패", message: "이메일 형식이 올바르지 않습니다.")
                    case AuthErrorCode.userNotFound.rawValue:
                        AlertHelper.alertWithConfirmButton(on: self!, with: "로그인 실패", message: "존재하지 않는 이메일입니다.")
                    case AuthErrorCode.wrongPassword.rawValue:
                        AlertHelper.alertWithConfirmButton(on: self!, with: "로그인 실패", message: "비밀번호가 올바르지 않습니다.")
                    default:
                        print("에러 발생 : \(error)")
                    }
                }
                return
            }

            // 로그인 성공시 ID 띄우기
            if let authResult = authResult {
                print("로그인 성공: 사용자 ID - \(authResult.user.uid)")
//                userInfo = await GlobalUserManager.shared.getOrCreateUserModel(uid: authResult.user.uid, db: db)
//                print("유저 정보 생성 : \(userInfo)")
            }
            
            // 로그인 성공 팝업 띄우기
            AlertHelper.showAlertWithNoButton(on: strongSelf, with: "로그인 성공", message: "메인 화면으로 이동합니다.")
        }
    }
    
    // 회원가입 화면으로 이동하는 함수
    @IBAction func tapGotoSignUp(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            signUpViewController.modalPresentationStyle = .formSheet
            present(signUpViewController, animated: true, completion: nil)
        }
    }
}
