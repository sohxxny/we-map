//
//  globalFriendsManager.swift
//  WeMap
//
//  Created by Lee Soheun on 4/28/24.
//

import Foundation
import FirebaseFirestore

// 친구 리스트를 전역적으로 관리하기 위한 클래스
class GlobalFriendsManager {
    
    static let shared = GlobalFriendsManager()
    var globalFriendsList: [UserViewModel] = []
    var globalFriendsModelList: [FriendsModel] = []
    var globalMyViewModel: UserViewModel?
    
    // 초기화 방지
    private init() {}
    
    // 유저 생성하기
    func createFriendsList(userInfo: UserModel) async {
        if globalFriendsList.isEmpty {
            (self.globalFriendsList, self.globalFriendsModelList) = await getFriendsInfo(userInfo: userInfo)
        }
    }
    
    func getFriendsList(userInfo: UserModel) async {
        (self.globalFriendsList, self.globalFriendsModelList) = await getFriendsInfo(userInfo: userInfo)
    }
    
    // 내 정보를 뷰 모델로 생성하기
    func createMyViewModel(userInfo: UserModel) async {
        if globalMyViewModel == nil {
            globalMyViewModel = await UserViewModel.createUserViewModel(email: userInfo.email)
        }
    }
    
    // 내 정보 업데이트
    func updateMyViewModel(name: String, message: String) {
        self.globalMyViewModel?.userName = name
        self.globalMyViewModel?.profileMessage = message
    }
    
    // 친구 리스트를 불러오기
    func getFriendsInfo(userInfo: UserModel) async -> ([UserViewModel], [FriendsModel]) {
        let db = Firestore.firestore()
        let friendsCollection = db.collection("userInfo").document(userInfo.uid).collection("friends")
        do {
            var userViewModelList: [UserViewModel] = []
            var friendsModelList: [FriendsModel] = []
            let querySnapshot = try await friendsCollection.getDocuments()
            for document in querySnapshot.documents {
                if let userInfo = await UserViewModel.createUserViewModel(email: document.documentID) {
                    let isBookMarked = document.data()["isBookMarked"] as! Bool
                    userViewModelList.append(userInfo)
                    friendsModelList.append(FriendsModel(user: userInfo, isBookMarked: isBookMarked))
                }
            }
            friendsModelList.sort { $0.user.userName < $1.user.userName }
            userViewModelList.sort { $0.userName < $1.userName }
            return (userViewModelList, friendsModelList)
        } catch {
            print("친구 목록 가져오기 에러: \(error)")
            return ([], [])
        }
    }
}
