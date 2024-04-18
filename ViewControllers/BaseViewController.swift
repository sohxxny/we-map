//
//  BaseViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 4/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class BaseViewController: UIViewController {
    
    var userInfo: UserModel!
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 화면 터치 시 키보드 내리기
        setupHideKeyboardOnTap()
    }

    // 화면 터치 시 키보드를 내리는 메서드
    func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
}
