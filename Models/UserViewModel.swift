//
//  UserViewModel.swift
//  WeMap
//
//  Created by Lee Soheun on 4/22/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

// 다른 유저 정보를 담는 모델
struct UserViewModel {
    var email: String
    var uid: String
    var userName: String
    var profilePhoto: UIImage?
    var profileMessage: String
    
    // 구조체 초기화
    init(email: String, uid: String, userName: String, profilePhoto: UIImage?, profileMessage: String) {
        self.email = email
        self.uid = uid
        self.userName = userName
        self.profilePhoto = profilePhoto
        self.profileMessage = profileMessage
    }
    
    // UserViewModel을 만드는 함수
    static func createUserViewModel(email: String) async -> UserViewModel? {
        guard let uid = await searchUserByEmail(email: email) else { return nil }
        let (userName, profilePhotoPath, profileMessage) = await getUserViewInfo(uid: uid)
        var profilePhoto: UIImage?
        if profilePhotoPath == "" {
            profilePhoto = nil
        } else {
            profilePhoto = await getImage(path: "profileImage/\(profilePhotoPath).jpg")
        }
        return UserViewModel(email: email, uid: uid, userName: userName, profilePhoto: profilePhoto, profileMessage: profileMessage)
    }
}

// 같은 유저인지 반환하는 함수
func isEqualUserViewModel(user1: UserViewModel, user2: UserViewModel) -> Bool {
    if user1.email == user2.email {
        return true
    }
    return false
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
                let profilePhotoPath = data?["profilePhoto"] as? String
                let profileMessage = data?["profileMessage"] as? String
                continuation.resume(returning: (userName!, profilePhotoPath!, profileMessage!))
            } else {
                continuation.resume(returning: ("empty name", "empty photo", "empty message"))
            }
        }
    }
}

// 파이어베이스에서 이미지 URL 가져오기
func getImageUrl(path: String) async -> URL? {
    let storageRef = Storage.storage().reference()
    let imageRef = storageRef.child(path)
    do {
        return try await imageRef.downloadURL()
    } catch {
        print("URL 다운로드 중 에러 발생: \(error)")
        return nil
    }
}

// 이미지 URL로부터 UIImage를 반환하는 함수
func getImage(path: String) async -> UIImage? {
    guard let url = await getImageUrl(path: path) else {
        print("URL 가져오기 에러 발생")
        return nil
    }

    // 이미지 데이터 가져오기
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    } catch {
        print("데이터를 로드하는 중 에러 발생: \(error)")
        return nil
    }
}

// 파이어베이스 이미지 삭제
func deleteImage(path: String) async {
    let storageRef = Storage.storage().reference()
    let imageRef = storageRef.child(path)
    do {
      try await imageRef.delete()
    } catch {
      print("이미지 삭제 실패 에러")
    }
        
}
