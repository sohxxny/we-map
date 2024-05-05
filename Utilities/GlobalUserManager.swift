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
    
    // 친구 신청 내역이 있는지 확인하는 함수 (sender가 receiver에게)
    func searchFriendsRequest(senderEmail: String, receiverEmail: String) async -> String? {
        let db = Firestore.firestore()
        if let uid = await searchUserByEmail(email: receiverEmail) {
            do {
                let notification = try await db.collection("userInfo").document(uid).collection("notification").getDocuments()
                for document in notification.documents {
                    if (document.data()["type"] as! String) == "friendsRequest" &&
                        (document.data()["userEmail"] as! String) == senderEmail {
                        return document.documentID
                    }
                }
            } catch {
                print("친구 요청 찾기 에러 발생 : \(error)")
                return nil
            }
        }
        print("친구 정보 없음")
        return ""
    }
    
    // 친구 신청 중인지 확인하는 함수
    func isFriendsRequesting(senderEmail: String, receiverEmail: String) async -> Bool? {
        if let friendsRequestId = await searchFriendsRequest(senderEmail: senderEmail, receiverEmail: receiverEmail) {
            if friendsRequestId == "" { return false }
            else { return true }
        }
        return nil
    }
    
    // 내 notification 데이터 가져오기
    func fetchNotification() async -> [NotificationModel] {
        var notificationModelList: [NotificationModel] = []
        let db = Firestore.firestore()
        do {
            let notificationDoc = try await db.collection("userInfo").document(globalUser!.uid).collection("notification").getDocuments()
            for document in notificationDoc.documents {
                let data = document.data()
                var type: NotificationType
                if (data["type"] as! String) == "friendsRequest" {
                    type = .friendsRequest
                } else {
                    type = .inviteAlbum
                }
                let userEmail = data["userEmail"] as! String
                let location = data["location"] as? String
                // 이메일로 친구 이름 찾기
                if let userUid = await searchUserByEmail(email: userEmail) {
                    let userDoc = db.collection("userInfo").document(userUid)
                    do {
                        let document = try await userDoc.getDocument()
                        if document.exists {
                            let userName = document.data()?["userName"] as! String
                            notificationModelList.append(NotificationModel(type: type, userName: userName, userEmail: userEmail, location: location))
                        }
                    }
                }
            }
        } catch {
            print("notification 컬렉션 가져오기 실패")
            return []
        }
        return notificationModelList
    }
    
    // 친구 요청 삭제
    func deleteFriendsRequest(senderEmail: String, receiverEmail: String, receiverUid: String) async {
        let db = Firestore.firestore()
        do {
            if let documentId = await GlobalUserManager.shared.searchFriendsRequest(senderEmail: senderEmail, receiverEmail: receiverEmail) {
                try await db.collection("userInfo").document(receiverUid).collection("notification").document(documentId).delete()
            }
        } catch {
            print("친구 요청 삭제 에러")
        }
    }
    
    // 친구 추가
    func addFriends(firstUserUid: String, firstUserEmail: String, secondUserUid: String, secondUserEmail: String) async {
        let db = Firestore.firestore()
        do {
            try await db.collection("userInfo").document(secondUserUid).collection("friends").document(firstUserEmail).setData([
                "isBookMarked": false
            ])
            try await db.collection("userInfo").document(firstUserUid).collection("friends").document(secondUserEmail).setData([
                "isBookMarked": false
            ])
        } catch {
            print("친구 추가 에러")
        }
    }
    
    // 내 프로필 이미지 경로 변경 (이메일 또는 공백)
    func setProfileImagePath(path: String) async {
        let db = Firestore.firestore()
        let userInfoDoc = db.collection("userInfo").document(self.globalUser!.uid)
        do {
            try await userInfoDoc.updateData([
                "profilePhoto" : path])
        } catch {
            print("프로필 이미지 경로 수정 에러 발생")
        }
    }
}
