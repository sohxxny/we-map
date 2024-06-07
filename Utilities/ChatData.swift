//
//  ChatData.swift
//  WeMap
//
//  Created by Lee Soheun on 6/1/24.
//

import Foundation
import UIKit
import FirebaseDatabase

// 채팅을 저장하는 함수
func saveChatMessage(documentId: String, messageText: String, by senderEmail: String) {
    let ref = Database.database().reference(withPath: documentId)
    let newMessageRef = ref.childByAutoId()
    let messageData = [
        "text": messageText,
        "senderEmail": senderEmail,
        "timeStamp": ServerValue.timestamp()
    ] as [String : Any]
    newMessageRef.setValue(messageData)
}

// 데이터를 읽어오는 함수
func getAllChat(documentId: String) async -> [[String: Any]] {
    let messagesRef = Database.database().reference(withPath: documentId)
    var messages: [[String: Any]] = []
    return await withCheckedContinuation { continuation in
        messagesRef.queryOrdered(byChild: "timeStamp").observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot, let message = childSnapshot.value as? [String: Any] {
                    messages.append(message)
                }
            }
            continuation.resume(returning: messages)
        })
    }
}

// 딕셔너리 형태의 데이터를 ChatModel로 바꾸는 작업
func createChatModelList(documentId: String, userList: [AlbumMemberModel]) async -> [ChatModel] {
    let data = await getAllChat(documentId: documentId)
    var messages: [ChatModel] = []
    for chat in data {
        let text = chat["text"] as! String
        let senderEmail = chat["senderEmail"] as! String
        let timeStamp = chat["timeStamp"] as! Int64
        let user = matchUserViewModel(find: senderEmail, in: userList)
        messages.append(ChatModel(user: user, content: text, timeStatmp: timeStamp))
    }
    return messages
}

// 이메일로 특정 UserViewModel 찾기
func matchUserViewModel(find email: String, in userList: [AlbumMemberModel]) -> UserViewModel {
    var userViewModel: UserViewModel!
    for userInfo in userList {
        if email == userInfo.user.email {
            userViewModel = userInfo.user
        }
    }
    return userViewModel
}

// 마지막 채팅을 읽어오는 함수
func getLastChat(documentId: String) async -> String? {
    let messagesRef = Database.database().reference(withPath: documentId)
    let query = messagesRef.queryOrdered(byChild: "timeStamp").queryLimited(toLast: 1)
    
    return await withCheckedContinuation { continuation in
        query.observeSingleEvent(of: .value, with: { snapshot in
            if let child = snapshot.children.allObjects.first as? DataSnapshot,
               let messageData = child.value as? [String: Any],
               let text = messageData["text"] as? String {
                continuation.resume(returning: text)
            } else {
                continuation.resume(returning: nil)
            }
        })
    }
}

