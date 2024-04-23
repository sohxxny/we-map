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
    
    // 내 친구인지 확인하는 코드
    func isFriends(userEmail: String, db: Firestore) async -> Bool? {
        do {
            let uid = self.globalUser!.uid
            let friendsCollection = try await db.collection("userInfo").document(uid).collection("friends").getDocuments()
            for document in friendsCollection.documents {
                if userEmail == document.documentID {
                    return true
                }
            }
            return false
        } catch {
            print("친구 확인 에러 발생")
            return nil
        }
    }
    
    // 친구 신청 중인지 확인하는 코드
    func isFriendsRequesting(userEmail: String, db: Firestore) async -> Bool? {
        do {
            let uid = self.globalUser!.uid
            let friendsCollection = try await db.collection("userInfo").document(uid).collection("friendsRequest").getDocuments()
            for document in friendsCollection.documents {
                if userEmail == document.documentID {
                    return true
                }
            }
            return false
        } catch {
            print("친구 확인 에러 발생")
            return nil
        }
    }
    
    // 비동기적으로 친구 목록 및 정보를 갖고 오는 함수 (수정 필요)
    func getFriendsInfo(userInfo : UserModel, db: Firestore) async -> [UserViewModel] {
        let uid = userInfo.uid
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
                        return UserViewModel(uid: document.documentID, email: email, userName: userName, photo: "")
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
