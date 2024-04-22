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
