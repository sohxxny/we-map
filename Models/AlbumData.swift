//
//  albumData.swift
//  WeMap
//
//  Created by Lee Soheun on 5/20/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

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

// 이미지 리스트를 앨범에 저장
func saveImage(_ image: UIImage, in albumRef: DocumentReference, completion: @escaping () -> Void) {
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
