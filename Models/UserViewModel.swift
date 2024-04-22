//
//  UserViewModel.swift
//  WeMap
//
//  Created by Lee Soheun on 4/22/24.
//

import Foundation
import FirebaseFirestore

// 다른 유저 정보를 담는 모델
struct UserViewModel {
    var uid: String
    var email: String
    var userName: String
    var photo: String
    
    // 구조체 초기화
    init(uid: String, email: String, userName: String, photo: String) {
        self.uid = uid
        self.email = email
        self.userName = userName
        self.photo = photo
    }
}

// 이메일로 유저 UID를 찾는 함수
func searchUserByEmail(email: String, db: Firestore) async -> String? {
    do {
        let userInfo = try await db.collection("userInfo").getDocuments()
        for document in userInfo.documents {
            if email == document.data()["email"] as! String {
                return document.documentID
            }
        }
        return nil
    } catch {
        print("유저 정보 찾기 에러 발생 : \(error)")
        return nil
    }
}

// 유저 정보에 대한 UserViewModel을 만드는 함수 (아직 프로필 사진 부분 수정 필요)
func loadUserViewData(uid: String, db: Firestore) async -> UserViewModel {
    let (userName, email) = await getUserViewInfo(uid: uid, db: db)
    return UserViewModel(uid: uid, email: email, userName: userName, photo: "")
}

// 비동기적으로 내 정보(이름, 이메일)를 갖고 오는 함수
func getUserViewInfo(uid: String, db: Firestore) async -> (String, String) {
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
