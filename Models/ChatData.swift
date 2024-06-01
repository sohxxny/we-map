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
    return await withCheckedContinuation { continuation in
        messagesRef.queryOrdered(byChild: "timeStamp").observeSingleEvent(of: .value, with: { snapshot in
            var messages: [[String: Any]] = []
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
func createChatModelList(documentId: String) async -> [ChatModel] {
    let chatDictionaryList = await getAllChat(documentId: documentId)
    var messages: [ChatModel] = []
    for chat in chatDictionaryList {
        let text = chat["text"] as! String
        let senderEmail = chat["senderEmail"] as! String
        let timeStamp = chat["timeStamp"] as! Int64
        let user = await UserViewModel.createUserViewModel(email: senderEmail)
        messages.append(ChatModel(user: user!, content: text, timeStatmp: timeStamp))
    }
    return messages
}

// 마지막 채팅을 읽어오는 함수
func getLastChat() {

}
