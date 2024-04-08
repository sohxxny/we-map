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
    var userName: String
    
    // UserViewModel 형식의 배열 선언 (친구 목록)
    var myFriends: Array<UserViewModel> = Array<UserViewModel>()
}

struct UserViewModel {
    var uid: String
    var email: String
    var userName: String
}

// 내 정보에 대한 UserModel을 만드는 함수
func loadUserData(uid: String, db: Firestore) async -> UserModel {
    // 내 정보 가져오기
    let (userName, email) = await getUserInfo(uid: uid, db: db)
    
    // 친구 목록 가져오기
    let friendsList: Array<UserViewModel> = await getFriendsInfo(uid: uid, db: db)

    // userModel 인스턴스 생성하여 반환하기
    return UserModel(uid: uid, email: email, userName: userName, myFriends: friendsList)

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

// 비동기적으로 친구 목록 및 정보를 갖고 오는 함수
func getFriendsInfo(uid: String, db: Firestore) async -> [UserViewModel] {
    let friendsCollection = db.collection("userInfo").document(uid).collection("friends")
    do {
        let querySnapshot = try await friendsCollection.getDocuments()
        var friendsList: [UserViewModel] = []
        
        // TaskGroup을 사용하여 각 친구 정보를 병렬로 가져오기
        await withTaskGroup(of: UserViewModel.self) { group in
            for document in querySnapshot.documents {
                group.addTask {
                    // 유저 정보를 가져오는 함수를 통해 정보 가져오기
                    let (userName, email) = await getUserInfo(uid: document.documentID, db: db)
                    return UserViewModel(uid: document.documentID, email: email, userName: userName)
                }
            }
            for await userViewModel in group {
                friendsList.append(userViewModel)
            }
        }
        return friendsList
    } catch {
        print("친구 목록 가져오기 에러: \(error)")
        return []
    }
}
