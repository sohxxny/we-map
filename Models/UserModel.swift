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
    var albumCoordinateList: [(Double, Double)] = []
    
    // 구조체 초기화
    init(uid: String, email: String, userName: String) {
        self.uid = uid
        self.email = email
        self.userName = userName
    }
}

// 내 정보에 대한 UserModel을 만드는 함수
func loadUserData(uid: String) async -> UserModel {
    let (userName, email) = await getUserInfo(uid: uid)
    return UserModel(uid: uid, email: email, userName: userName)
}

// 비동기적으로 내 정보(이름, 이메일)를 갖고 오는 함수
func getUserInfo(uid: String) async -> (String, String) {
    await withCheckedContinuation { continuation in
        let db = Firestore.firestore()
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

// 앨범 문서의 참조를 내 정보에 저장하는 함수
func addAlbumRef(_ albumRef: DocumentReference, in user: UserModel) {
    let db = Firestore.firestore()
    let userRef = db.collection("userInfo").document(user.uid).collection("joinedAlbum").document()
    userRef.setData(["albumRef": albumRef])
}

// 앨범들의 좌표를 가져오는 함수
func getAlbumCoordinate(uid: String) async -> [(Double, Double)]? {
    let db = Firestore.firestore()
    var albumCoordinateList = [(Double, Double)]()
    do {
        let joinedAlbum = try await db.collection("userInfo").document(uid).collection("joinedAlbum").getDocuments()
        for document in joinedAlbum.documents {
            if let albumRef = document.get("albumRef") as? DocumentReference {
                let doc = try await albumRef.getDocument()
                if doc.exists {
                    if let geoPoint = doc.data()?["coordinate"] as? GeoPoint {
                        let coordinate = (geoPoint.latitude, geoPoint.longitude)
                        if !albumCoordinateList.contains(where: { $0 == coordinate }) {
                            albumCoordinateList.append(coordinate)
                        }
                    }
                }
            }
        }
    } catch {
        print("앨범 좌표 리스트 가져오기 실패")
        return nil
    }
    return albumCoordinateList
}
