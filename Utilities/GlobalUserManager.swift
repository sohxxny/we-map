//
//  GlobalUserManager.swift
//  WeMap
//
//  Created by Lee Soheun on 4/18/24.
//

import Foundation
import FirebaseFirestore

// 로그인 정보를 전역적으로 관리하기 위한 싱글톤 클래스
class GlobalUserManager {
    
    static let shared = GlobalUserManager()
    private(set) var globalUser: UserModel?
    
    // 초기화 방지
    private init() {}
    
    // 유저 가져오기 또는 생성하기
    func getOrCreateUserModel(uid: String, db: Firestore) async -> UserModel {
        if let user = globalUser {
            return user
        } else {
            let newUser = await loadUserData(uid: uid, db: db)
            globalUser = newUser
            return newUser
        }
    }
    
    func logOutUser() {
            globalUser = nil
        }
    
    // 비동기적으로 친구 목록 및 정보를 갖고 오는 함수
    // let friendsList: Array<UserViewModel> = await getFriendsInfo(uid: uid, db: db)
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
}
