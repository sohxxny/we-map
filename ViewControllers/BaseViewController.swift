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
    
    var handle: AuthStateDidChangeListenerHandle?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 화면 터치 시 키보드 내리기
        setupHideKeyboardOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 로그인 여부 판단 리스너
        setupAuthListener()
        
        // userInfo 생성 및 친구 목록 생성
        Task {
            await createUserInfo()
            if let userInfo = GlobalUserManager.shared.globalUser {
                await GlobalFriendsManager.shared.createMyViewModel(userInfo: userInfo)
                await GlobalFriendsManager.shared.createFriendsList(userInfo: userInfo)
                if let albumCoordinateList = await getAlbumCoordinateList(uid: userInfo.uid) {
                    GlobalUserManager.shared.globalUser?.albumCoordinateList = albumCoordinateList
                } else {
                    print("앨범 리스트 가져오기 실패")
                }
                // 데이터 로드 완료되면 UI 띄우기
                updateUI()
            }
        }
    }
    
    // 로그인 여부 판단 리스너
    func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            // 로그인 상태인 경우
            if user != nil {
                print("로그인 상태")
            // 로그아웃 상태인 경우 현재 로그인 화면이 아니라면 로그인 화면으로 이동
            } else {
                print("로그아웃 상태")
                if !(self is SignInViewController) && !(self is SignUpViewController) {
                    self?.goToSignIn()
                }
            }
        }
    }
    
    // userInfo 생성하기
    func createUserInfo() async {
        if let user = Auth.auth().currentUser {
            await GlobalUserManager.shared.createUserModel(uid: user.uid)
        }
    }

    // UI 업데이트
    func updateUI() {
        // 상속된 클래스에서 정의
    }
    
    // 로그인 화면으로 이동하는 함수
    func goToSignIn() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signInViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
            signInViewController.modalPresentationStyle = .fullScreen
            present(signInViewController, animated: true, completion: nil)
        }
    }

    // 화면 터치 시 작동하는 함수
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
    
    // 제스처 이벤트 받는 함수
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
