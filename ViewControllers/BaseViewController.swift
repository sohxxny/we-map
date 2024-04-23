//
//  BaseViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 4/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var userInfo: UserModel!
    var handle: AuthStateDidChangeListenerHandle?
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // firestore 인스턴스 초기화
        db = Firestore.firestore()
        
        // 화면 터치 시 키보드 내리기
        setupHideKeyboardOnTap()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 로그인 여부 판단 리스너
        setupAuthListener()
    }
    
    // 로그인 상태가 아닐 경우 로그인 화면으로 전환하는 함수
    func setupAuthListener() {
        // 로그인 상태인 경우
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if let user = user {
                Task {
                    if let self = self {
                        self.userInfo = await GlobalUserManager.shared.getOrCreateUserModel(uid: user.uid, db: self.db)
                        print("로그인 상태, userInfo: \(String(describing: self.userInfo))")
                    }
                }
            // 로그아웃 상태인 경우
            } else {
                print("로그아웃 상태")
                // 현재 로그인 화면이 아니라면 로그인 화면으로 이동
                if !(self is SignInViewController) && !(self is SignUpViewController) {
                    self!.goToSignIn()
                }
            }
        }
    }
    
    // 로그인 화면으로 이동하는 함수
    func goToSignIn() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signInViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
            signInViewController.modalPresentationStyle = .fullScreen
            present(signInViewController, animated: true, completion: nil)
        }
    }

    // 화면 터치 시 작동하는 메서드
    func setupHideKeyboardOnTap() {
        let hideKeyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideKeyboardTapGesture.delegate = self
        hideKeyboardTapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(hideKeyboardTapGesture)
    }

    // 키보드 내리기 함수
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    
}
