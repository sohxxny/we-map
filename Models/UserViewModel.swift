//
//  UserViewModel.swift
//  WeMap
//
//  Created by Lee Soheun on 4/22/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

// 다른 유저 정보를 담는 모델
struct UserViewModel {
    var email: String
    var uid: String
    var userName: String
    var profilePhoto: String
    var profileMessage: String
    
    // 구조체 초기화
    init(email: String, uid: String, userName: String, profilePhoto: String, profileMessage: String) {
        self.email = email
        self.uid = uid
        self.userName = userName
        self.profilePhoto = profilePhoto
        self.profileMessage = profileMessage
    }
    
    // UserViewModel을 만드는 함수
    static func createUserViewModel(email: String) async -> UserViewModel? {
        guard let uid = await searchUserByEmail(email: email) else { return nil }
        let (userName, profilePhoto, profileMessage) = await getUserViewInfo(uid: uid)
        return UserViewModel(email: email, uid: uid, userName: userName, profilePhoto: profilePhoto, profileMessage: profileMessage)
    }
}

// 이메일로 유저 UID를 찾는 함수
func searchUserByEmail(email: String) async -> String? {
    let db = Firestore.firestore()
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

// 비동기적으로 유저 정보(이름, 사진, 프로필 메시지)를 갖고 오는 함수
func getUserViewInfo(uid: String) async -> (String, String, String) {
    return await withCheckedContinuation { continuation in
        let db = Firestore.firestore()
        let myInfo = db.collection("userInfo").document(uid)
        myInfo.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let userName = data?["userName"] as? String
                let profilePhoto = data?["profilePhoto"] as? String
                let profileMessage = data?["profileMessage"] as? String
                continuation.resume(returning: (userName!, profilePhoto!, profileMessage!))
            } else {
                continuation.resume(returning: ("empty name", "empty photo", "empty message"))
            }
        }
    }
}
