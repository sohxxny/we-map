//
//  albumData.swift
//  WeMap
//
//  Created by Lee Soheun on 5/20/24.
//

import Foundation
import FirebaseFirestore

func joinAlbum(albumRef: DocumentReference, userInfo: UserModel) {
    let memberRef = albumRef.collection("member").document(userInfo.email)
    memberRef.updateData(["isJoined": true])
}
