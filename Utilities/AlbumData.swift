//
//  albumData.swift
//  WeMap
//
//  Created by Lee Soheun on 5/20/24.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseDatabase

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
    }
    return nil
}

// 나를 앨범에 합류
func joinAlbum(albumRef: DocumentReference, userInfo: UserModel) {
    let memberRef = albumRef.collection("member").document(userInfo.email)
    memberRef.updateData(["isJoined": true])
}

// 나를 앨범에서 삭제
func deleteMember(albumRef: DocumentReference, userInfo: UserModel) async {
    let db = Firestore.firestore()
    do {
        try await albumRef.collection("member").document(userInfo.email).delete()
        let userRef = try await db.collection("userInfo").document(userInfo.uid).collection("joinedAlbum").getDocuments()
        for albumDoc in userRef.documents {
            let ref = albumDoc.data()["albumRef"] as? DocumentReference
            if ref == albumRef {
                try await db.collection("userInfo").document(userInfo.uid).collection("joinedAlbum").document(albumDoc.documentID).delete()
            }
        }
    } catch {
        print("앨범에서 유저 삭제 에러")
    }
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

func createAllAlbumPreviewModel(userInfo: UserModel) async -> [AlbumPreviewModel] {
    var previewList: [AlbumPreviewModel] = []
    let db = Firestore.firestore()
    do {
        let joinedAlbumRef = try await db.collection("userInfo").document(userInfo.uid).collection("joinedAlbum").getDocuments()
        for document in joinedAlbumRef.documents {
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
    } catch {
        print("앨범 프리뷰 모델 리스트 생성 에러")
    }
    previewList.sort(by: { $0.timeStamp.nanoseconds > $1.timeStamp.nanoseconds })
    previewList.sort(by: { $0.timeStamp.seconds > $1.timeStamp.seconds })
    return previewList
}

// 앨범 주소 및 이름 가져오기
func getAlbumNameAndAddress(albumRef: DocumentReference) async -> (String, String)? {
    do {
        let doc = try await albumRef.getDocument()
        if doc.exists {
            if let address = doc.data()?["address"] as? String, let albumName = doc.data()?["albumName"] as? String {
                return (albumName, address)
            }
        }
    } catch {
        print("앨범 이름 주소 가져오기 실패")
    }
    return nil
}

// 멤버 정보 가져오기
func getMemberInfo(albumRef: DocumentReference, userInfo: UserModel) async -> [AlbumMemberModel]? {
    var memberInfoList: [AlbumMemberModel] = []
    var myInfo: AlbumMemberModel!
    do {
        let memberRef = try await albumRef.collection("member").getDocuments()
        for document in memberRef.documents {
            let userEmail = document.documentID
            let isJoined: Bool = document.data()["isJoined"] as! Bool
            // 내 정보는 따로 저장
            if userEmail == userInfo.email {
                let myViewModel = await UserViewModel.createUserViewModel(email: userEmail)!
                myInfo = AlbumMemberModel(user: myViewModel, isJoined: isJoined)
            } else {
                let userViewModel = await UserViewModel.createUserViewModel(email: userEmail)
                memberInfoList.append(AlbumMemberModel(user: userViewModel!, isJoined: isJoined))
            }
        }
        // 가나다순 정렬, 내 정보를 가장 앞으로
        memberInfoList.sort(by: { $0.user.userName < $1.user.userName })
        memberInfoList.insert(myInfo, at: 0)
        return memberInfoList
    } catch {
        print("멤버 정보 가져오기 실패")
    }
    return nil
}

// 멤버 수 가져오기
func getMemberNum(albumRef: DocumentReference) async -> Int {
    var memberNum: Int = 1
    do {
        let memberRef = try await albumRef.collection("member").getDocuments()
        memberNum = memberRef.documents.count
    } catch {
        print("멤버 수 세기 실패")
    }
    return memberNum
}

// 앨범 대표 이미지 있는지 확인
func checkMainImage(albumRef: DocumentReference) async -> Bool {
    let db = Firestore.firestore()
    do {
        let doc = try await albumRef.getDocument()
        if doc.exists {
            if let mainImage = doc.data()?["mainImage"] as? DocumentReference {
                return true
            }
        }
    } catch {
        print("앨범 대표 이미지 확인 실패")
    }
    return false
}

// 앨범 대표 이미지 저장

// 이미지를 앨범에 저장
func saveImage(_ image: UIImage, in albumRef: DocumentReference, completion: @escaping () -> Void) -> DocumentReference {
    let photoRef = albumRef.collection("photo").document()
    photoRef.setData(["timeStamp": FieldValue.serverTimestamp()])
    
    // 이미지 저장
    let imageName: String = photoRef.documentID
    let albumDocId: String = albumRef.documentID
    if let imageData = image.jpegData(compressionQuality: 0.75) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("memoryAlbum/\(albumDocId)/photo/\(imageName).jpg")
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("에러 발생 : \(error)")
                completion()
            } else {
                print("image info : \(image)")
                completion()
            }
        }
    }
    
    return photoRef
}

// 앨범으로부터 이미지 리스트를 불러오기
func getAlbumImageList(in albumRef: DocumentReference) async -> [PhotoViewModel] {
    var photoList: [PhotoViewModel] = []
    let albumDocId: String = albumRef.documentID
    do {
        let photos = try await albumRef.collection("photo").getDocuments()
        for document in photos.documents {
            let photoRef = albumRef.collection("photo").document(document.documentID)
            if let timeStamp = document.data()["timeStamp"] as? Timestamp, let image = await getImage(path: "memoryAlbum/\(albumDocId)/photo/\(document.documentID).jpg") {
                photoList.append(PhotoViewModel(image: image, photoRef: photoRef, timeStamp: timeStamp))
            }
        }
    } catch {
        print("앨범 이미지 불러오기 실패")
    }
    photoList.sort(by: { $0.timeStamp.nanoseconds > $1.timeStamp.nanoseconds })
    photoList.sort(by: { $0.timeStamp.seconds > $1.timeStamp.seconds })
    return photoList
}

// 특정 경로의 데이터 모두 삭제하기
func deleteStorageData(path: String) {
    let storageRef = Storage.storage().reference().child(path)
    storageRef.listAll { (result, error) in
        if let error = error {
            print("Error listing files: \(error)")
            return
        }
        for item in result!.items {
            item.delete { error in
                if let error = error {
                    print("Error deleting item: \(error)")
                } else {
                    print("Item deleted successfully: \(item.fullPath)")
                }
            }
        }
        for prefix in result!.prefixes {
            deleteStorageData(path: prefix.fullPath)
        }
    }
}

// 앨범의 미디어 데이터 지우기
func deleteAlbumMedia(albumRef: DocumentReference) {
    let albumID = albumRef.documentID
    deleteStorageData(path: "memoryAlbum/\(albumID)/photo")
    deleteStorageData(path: "memoryAlbum/\(albumID)/video")
}

// 앨범 구성원 정보 지우기
func deleteAlbumMember(albumRef: DocumentReference) async {
    let db = Firestore.firestore()
    do {
        let memberRef = try await albumRef.collection("member").getDocuments()
        for document in memberRef.documents {
            if let memberUid = document.data()["uid"] as? String, let isJoined = document.data()["isJoined"] as? Bool {
                // 들어와있다면 해당 멤버 정보의 joinedAlbum에서 albumRef와 같은 문서 지우기
                if isJoined {
                    let userRef = try await db.collection("userInfo").document(memberUid).collection("joinedAlbum").getDocuments()
                    for albumDoc in userRef.documents {
                        let ref = albumDoc.data()["albumRef"] as? DocumentReference
                        if ref == albumRef {
                            try await db.collection("userInfo").document(memberUid).collection("joinedAlbum").document(albumDoc.documentID).delete()
                        }
                    }
                } else {
                    // 들어와있지 않다면 해당 멤버 정보의 notification에서 앨범 지우기
                    let userRef = try await db.collection("userInfo").document(memberUid).collection("notification").getDocuments()
                    for albumDoc in userRef.documents {
                        if let notificationType = albumDoc.data()["type"] as? String, let ref = albumDoc.data()["albumRef"] as? DocumentReference {
                            if ref == albumRef && notificationType == "inviteAlbum" {
                                try await db.collection("userInfo").document(memberUid).collection("notification").document(albumDoc.documentID).delete()
                            }
                        }
                    }
                }
            }
        }
    } catch {
        print("앨범 구성원 정보 지우기 에러")
    }
}

// 앨범 채팅 지우기
func deleteAlbumChat(documentId: String) {
    let ref = Database.database().reference(withPath: documentId)
    ref.removeValue { error, _ in
        if let error = error {
            print("채팅 삭제 에러: \(error)")
        }
    }
}

// 앨범 삭제
func deleteAlbum(albumRef: DocumentReference) async {
    do {
        deleteAlbumMedia(albumRef: albumRef)
        deleteAlbumChat(documentId: albumRef.documentID)
        await deleteAlbumMember(albumRef: albumRef)
        let db = Firestore.firestore()
        let albumID = albumRef.documentID
        try await db.collection("memoryAlbum").document(albumID).delete()
    } catch {
        print("앨범 삭제 에러")
    }
}
