//
//  SignUpViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 2024/01/24.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class SignUpViewController: BaseViewController {
    
    // Outlet 변수들
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwdTextField: CustomTextField!
    @IBOutlet weak var passwdCheckTextField: CustomTextField!
    @IBOutlet weak var userNameTextField: CustomTextField!

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwdLabel: UILabel!
    @IBOutlet weak var passwdCheckLabel: UILabel!
    
    @IBOutlet weak var signUpButton: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 텍스트 필드 입력 감지
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        passwdTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        passwdCheckTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    // 텍스트 필드의 입력을 실시간으로 확인하는 함수
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let email = emailTextField.text, let passwd = passwdTextField.text, let passwdCheck = passwdCheckTextField.text else { return }

        // 이메일 형식이 맞지 않은 경우
        let emailRegEx = "[A-Z0-9a-z]+@[A-Za-z0-9]+\\.[a-z]{2,3}$"
        if email.range(of: emailRegEx, options: .regularExpression) == nil {
            emailLabel.text = "이메일 형식이 올바르지 않습니다."
        } else {
            emailLabel.text = ""
        }
        
        // 비밀번호가 8자리 미만인 경우
        if passwd.count != 0 && passwd.count < 8 {
            passwdLabel.text = "비밀번호를 8자리 이상으로 설정해주세요."
        } else {
            passwdLabel.text = ""
        }
        
        // 비밀번호와 비밀번호 확인이 다른 경우
        if passwdCheck != passwd {
            passwdCheckLabel.text = "비밀번호를 확인해주세요."
        } else {
            passwdCheckLabel.text = ""
        }

    }
    
    // 회원가입 버튼 클릭 액션 함수
    @IBAction func SignUpButtonTapped(_ sender: UIButton) {
        // 텍스트 필드가 비어 있는지 확인
        guard let email = emailTextField.text, !email.isEmpty,
              let passwd = passwdTextField.text, !passwd.isEmpty,
              let passwdCheck = passwdCheckTextField.text, !passwdCheck.isEmpty,
              let userName = userNameTextField.text, !userName.isEmpty else {
            // 하나라도 비어 있다면 사용자에게 알리고 함수 종료
            AlertHelper.alertWithConfirmButton(on: self, with: nil, message: "모든 정보를 기입해주세요.")
            return
        }
        
        // 텍스트 필드에 정상적으로 입력이 되었는지 확인
        guard let emailError = emailLabel.text, emailError == "",
              let passwdError = passwdLabel.text, passwdError == "",
              let passwdCheckError = passwdCheckLabel.text, passwdCheckError == "" else {
            // 잘못된 정보를 기입했다면 사용자에게 알리고 함수 종료
            AlertHelper.alertWithConfirmButton(on: self, with: nil, message: "정보를 다시 한 번 확인해 주세요.")
            return
        }
        
        // 회원 가입 함수 호출
        signUp(email: email, passwd: passwd, userName: userName)
    }
    
    func signUp(email: String, passwd: String, userName: String) {
        Auth.auth().createUser(withEmail: email, password: passwd) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                if let error = error as NSError? {
                    if error.domain == AuthErrorDomain {
                        switch (error.code) {
                        case AuthErrorCode.emailAlreadyInUse.rawValue:
                            AlertHelper.alertWithConfirmButton(on: self, with: "회원가입 실패", message: "이미 존재하는 이메일입니다.")
                        case AuthErrorCode.invalidEmail.rawValue:
                            AlertHelper.alertWithConfirmButton(on: self, with: "회원가입 실패", message: "이메일 형식이 올바르지 않습니다.")
                        default:
                            print("회원 가입 오류: \(error)")
                        }
                    }
                }
                return
            }
            
            // 회원 가입 성공 시 처리
            // uid로 구분된 문서 생성
            self.createUserInfo(uid: user.uid, email: email, userName: userName)
            
            // 회원가입 성공 팝업
            AlertHelper.showAlertWithNoButton(on: self, with: "회원가입 성공", message: "로그인 화면으로 이동합니다.")
            
            // 로그인 화면으로 이동
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // 사용자 이메일로 된 파이어베이스 문서를 생성하는 함수
    func createUserInfo(uid: String, email: String, userName: String) {
        let userRef = db.collection("userInfo").document(uid)
        userRef.setData([
            "uid": uid,
            "email" : email,
            "userName": userName,
            "profilePhoto" : ""
        ]) { error in
            if let error = error {
                print("사용자 정보 생성 오류: \(error.localizedDescription)")
            } else {
                print("사용자 정보가 성공적으로 생성되었습니다.")
            }
        }
    }
    
    // 로그인 화면으로 돌아가기 버튼
    @IBAction func tapBackToSignIn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
