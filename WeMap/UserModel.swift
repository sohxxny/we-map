//
//  UserModel.swift
//  WeMap
//
//  Created by Lee Soheun on 4/7/24.
//

import Foundation
import FirebaseFirestore

struct UserModel {
    var uid: String
    var email: String
    var name: String
    
    // UserViewModel 형식의 배열 선언 (친구 목록)
    var myFriends: Array<UserViewModel> = Array<UserViewModel>()
}

struct UserViewModel {
    var uid: String
    var email: String
    var name: String
}

func loadUserData(uid: String, db: Firestore) -> UserModel {
    // 클로저 외부에서 쓸 수 있도록 변수 선언
    var email = "empty email"
    var name = "empty name"
    var friendsList: Array<UserViewModel> = Array<UserViewModel>()
    
    let myInfo = db.collection("userInfo").document(uid)
    
    // 내 이메일, 이름 갖고오기
    myInfo.getDocument { document, error in
        if let document = document, document.exists {
            let data = document.data()
            email = data?["email"] as? String ?? ""
            name = data?["name"] as? String ?? ""
        }}
    
    // 친구 목록 가져오기
    let friendsCollection = db.collection("userInfo").document(uid).collection("friends")
    friendsCollection.getDocuments() { (querySnapshot, error) in
        if let error = error {
            print("친구 목록 가져오기 에러: \(error)")
        } else {
            // 친구 uid 조회 후 해당 정보로 UserViewModel 인스턴스 생성
            for document in querySnapshot!.documents {
                var friendsInfo = db.collection("userInfo").document(document.documentID)
                friendsInfo.getDocument { doc, err in
                    if let doc = doc, doc.exists {
                        let data = doc.data()
                        let email = data?["email"] as? String ?? ""
                        let name = data?["name"] as? String ?? ""
                        
                        // UserViewModel 인스턴스를 친구 목록 배열에 추가
                        friendsList.append(UserViewModel(uid: document.documentID, email: email, name: name))
                    }}
            }
        }
    }
    // userModel 인스턴스 생성하여 반환하기
    var userModel = UserModel(uid: uid, email: email, name: name, myFriends: friendsList)
    return userModel

}
