//
//  GlobalUserManager.swift
//  WeMap
//
//  Created by Lee Soheun on 4/18/24.
//

import Foundation
import FirebaseFirestore

// 로그인 정보를 전역적으로 관리하기 위한 싱글턴 클래스
class GlobalUserManager {
    
    static let shared = GlobalUserManager()
    var globalUser: UserModel?
    
    // 초기화 방지
    private init() {}
    
    // 유저 가져오기 또는 생성하기
    func createUserModel(uid: String) async {
        if globalUser == nil {
            globalUser = await loadUserData(uid: uid)
        }
    }
    
    func logOutUser() {
            globalUser = nil
        }
    
    // 내 친구인지 확인하는 코드
    func isFriends(userEmail: String) async -> Bool? {
        let db = Firestore.firestore()
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
    func isFriendsRequesting(userEmail: String) async -> Bool? {
        let db = Firestore.firestore()
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
}
