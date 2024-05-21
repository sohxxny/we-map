//
//  albumData.swift
//  WeMap
//
//  Created by Lee Soheun on 5/20/24.
//

import Foundation
import FirebaseFirestore

// 앨범 문서의 참조를 내 정보에 저장하는 함수
func addAlbumRef(_ albumRef: DocumentReference, in user: UserModel) {
    let db = Firestore.firestore()
    let userRef = db.collection("userInfo").document(user.uid).collection("joinedAlbum").document()
    userRef.setData(["albumRef": albumRef])
}

// 앨범들의 좌표를 가져오는 함수
func getAlbumCoordinateList(uid: String) async -> [(Double, Double)]? {
    let db = Firestore.firestore()
    var albumCoordinateList = [(Double, Double)]()
    do {
        let joinedAlbum = try await db.collection("userInfo").document(uid).collection("joinedAlbum").getDocuments()
        for document in joinedAlbum.documents {
            if let coordinate = await getAlbumCoordinate(ref: document, uid: uid) {
                if !albumCoordinateList.contains(where: { $0 == coordinate }) {
                    albumCoordinateList.append(coordinate)
                }
            }
        }
    } catch {
        print("앨범 좌표 리스트 가져오기 실패")
        return nil
    }
    return albumCoordinateList
}

// 앨범 하나의 좌표를 가져오는 함수
func getAlbumCoordinate(ref: DocumentSnapshot, uid: String) async -> (Double, Double)? {
    let db = Firestore.firestore()
    do {
        if let albumRef = ref.get("albumRef") as? DocumentReference {
            let doc = try await albumRef.getDocument()
            if doc.exists {
                if let geoPoint = doc.data()?["coordinate"] as? GeoPoint {
                    return (geoPoint.latitude, geoPoint.longitude)
                }
            }
        }
    } catch {
        print("앨범 좌표 가져오기 실패")
        return nil
    }
    return nil
}

// 나를 앨범에 합류
func joinAlbum(albumRef: DocumentReference, userInfo: UserModel) {
    let memberRef = albumRef.collection("member").document(userInfo.email)
    memberRef.updateData(["isJoined": true])
}

// 해당 좌표의 앨범 데이터 가져와서 albumPreviewModel 모델로 만들기
func createAlbumPreviewModel(coordinate: (Double, Double), userInfo: UserModel) async -> [AlbumPreviewModel] {
    var previewList: [AlbumPreviewModel] = []
    let db = Firestore.firestore()
    do {
        let joinedAlbumRef = try await db.collection("userInfo").document(userInfo.uid).collection("joinedAlbum").getDocuments()
        for document in joinedAlbumRef.documents {
            if let albumCoordinate = await getAlbumCoordinate(ref: document, uid: userInfo.uid) {
                if (albumCoordinate.0 == coordinate.1) && (albumCoordinate.1 == coordinate.0) {
                    // 이 문서의 앨범 주소, 앨범 이름, 사진 가져오기
                    if let albumRef = document.data()["albumRef"] as? DocumentReference {
                        let doc = try await albumRef.getDocument()
                        if doc.exists {
                            let albumName = doc.data()?["albumName"] as? String
                            let timeStamp = doc.data()?["timeStamp"] as? Timestamp
                            // let featuredImage = doc.data()?["featuredImage"] as? String
                            
                            // featuredImage가 nil이 아닐 경우 이미지 구하기
                            
                            previewList.append(AlbumPreviewModel(albumRef: albumRef, albumName: albumName!, timeStamp: timeStamp!, featuredImage: nil))
                        }
                    }
                }
            }
        }
    } catch {
        print("앨범 프리뷰 모델 리스트 생성 에러")
    }
    return previewList
}