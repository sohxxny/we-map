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

class SignUpViewController: UIViewController {
    
    // Outlet 변수들
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var passwdCheckTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
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
    
    // 회원가입 버튼 클릭 액션 함수
    @IBAction func SignUpButtonTapped(_ sender: UIButton) {
        // 텍스트 필드가 비어 있는지 확인
        guard let email = emailTextField.text, !email.isEmpty,
              let passwd = passwdTextField.text, !passwd.isEmpty,
              let passwdCheck = passwdCheckTextField.text, !passwdCheck.isEmpty,
              let userName = userNameTextField.text, !userName.isEmpty else {
            // 하나라도 비어 있다면 사용자에게 알리고 함수 종료
            print("모든 정보를 기입해주세요.")
            return
        }
        // 회원 가입 함수 호출
        signUp(email: email, passwd: passwd, userName: userName)
    }
    
    func signUp(email: String, passwd: String, userName: String) {
        Auth.auth().createUser(withEmail: email, password: passwd) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                print("회원 가입 오류: \(error!.localizedDescription)")
                return
            }
            
            // 회원 가입 성공 시 처리
            // uid로 구분된 문서 생성
            self.createUserInfo(uid: user.uid, email: email, userName: userName)
            
            // 회원가입 성공 팝업
            AlertHelper.showAlertWithNoButton(on: self, with: "회원 가입 성공", message: "로그인 화면으로 이동합니다.")
            
            // 로그인 화면으로 이동
            self.performSegue(withIdentifier: "SignUpCompleteUnwindSegue", sender: self)
        }
    }
    
    // 사용자 uid로 된 파이어베이스 문서를 생성하는 함수
    func createUserInfo(uid: String, email: String, userName: String) {
        let userRef = db.collection("userInfo").document(uid)
        userRef.setData([
            // "uid": uid,
            "email": email,
            "userName": userName
        ]) { error in
            if let error = error {
                print("사용자 정보 생성 오류: \(error.localizedDescription)")
            } else {
                print("사용자 정보가 성공적으로 생성되었습니다.")
            }
        }
    }
    
    // 회원 가입 함수
    
    // 화면 터치 이벤트 함수
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        // 화면 터치 시 키보드 내리기
        self.view.endEditing(true)
    }

}