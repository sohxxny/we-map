//
//  UserModel.swift
//  WeMap
//
//  Created by Lee Soheun on 4/7/24.
//

import Foundation
import FirebaseFirestore

// 내 정보를 담는 모델
struct UserModel {
    var uid: String
    var email: String
    var userName: String
    
    // 구조체 초기화
    init(uid: String, email: String, userName: String) {
        self.uid = uid
        self.email = email
        self.userName = userName
    }
}

// 다른 유저 정보를 담는 모델
struct UserViewModel {
    var uid: String
    var email: String
    var userName: String
    
    // 구조체 초기화
    init(uid: String, email: String, userName: String) {
        self.uid = uid
        self.email = email
        self.userName = userName
    }
}

// 내 정보에 대한 UserModel을 만드는 함수
func loadUserData(uid: String, db: Firestore) async -> UserModel {
    let (userName, email) = await getUserInfo(uid: uid, db: db)
    return UserModel(uid: uid, email: email, userName: userName)
}

// 비동기적으로 내 정보(이름, 이메일)를 갖고 오는 함수
func getUserInfo(uid: String, db: Firestore) async -> (String, String) {
    await withCheckedContinuation { continuation in
        let myInfo = db.collection("userInfo").document(uid)
        myInfo.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let email = data?["email"] as? String ?? "empty email"
                let userName = data?["userName"] as? String ?? "empty name"
                continuation.resume(returning: (userName, email))
            } else {
                continuation.resume(returning: ("empty name", "empty email"))
            }
        }
    }
}
