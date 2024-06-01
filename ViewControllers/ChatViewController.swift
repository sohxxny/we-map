//
//  ChatViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/30/24.
//

import UIKit
import FirebaseFirestore

class ChatViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendChatButton: CustomFilledButton!
    @IBOutlet weak var chatTextView: ChatTextView!
    
    let dataList: [[String]] = []  // 임시 데이터 리스트
    var chatModelList: [ChatModel] = []
    var albumRef: DocumentReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        chatTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if chatTextView.text == "" {
            setButtonOn(button: sendChatButton, isOn: false)
        } else {
            setButtonOn(button: sendChatButton, isOn: true)
        }
        
        Task {
            chatModelList = await createChatModelList(documentId: albumRef.documentID)
            chatTableView.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 텍스트 필드 변경 감지
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        if text.isEmpty {
            setButtonOn(button: sendChatButton, isOn: false)
        } else {
            setButtonOn(button: sendChatButton, isOn: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatModelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let continuousChatCell = chatTableView.dequeueReusableCell(withIdentifier: "ContinuousChatTableViewCell", for: indexPath) as! ContinuousChatTableViewCell
        let myChatTableViewCell = chatTableView.dequeueReusableCell(withIdentifier: "MyChatTableViewCell", for: indexPath) as! MyChatTableViewCell
        let chatCell = chatTableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        let myInfo = GlobalUserManager.shared.globalUser!
        
        if chatModelList[indexPath.row].user.email == myInfo.email {
            myChatTableViewCell.chatContent.text = chatModelList[indexPath.row].content
            return myChatTableViewCell
        } else {
            if indexPath.row > 0 && chatModelList[indexPath.row].user.email == chatModelList[indexPath.row - 1].user.email {
                continuousChatCell.chatContent.text = chatModelList[indexPath.row].content
                return continuousChatCell
            } else {
                chatCell.profileName.text = chatModelList[indexPath.row].user.userName
                chatCell.chatContent.text = chatModelList[indexPath.row].content
                setIconImage(imageView: chatCell.profileImage, color: .weMapSkyBlue, icon: "user-icon")
                return chatCell
            }
        }
    }
    
    // 버튼 enabled 설정을 바꾸는 함수
    func setButtonOn(button: UIButton, isOn: Bool) {
        if isOn {
            button.isEnabled = true
            button.alpha = 1.0
        } else {
            button.isEnabled = false
            button.alpha = 0.5
        }
    }
    
    // 키보드 보이기 감지
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            stackViewBottomConstraint.constant = keyboardFrame.height - 20
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    // 키보드 숨기기 감지
    @objc func keyboardWillHide(notification: NSNotification) {
        stackViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // 전송 버튼 누를 시 키보드 내려가지 않도록 하기
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: sendChatButton) {
            return false
        }
        return super.gestureRecognizer(gestureRecognizer, shouldReceive: touch)
    }
    
    // 채팅 보내기
    @IBAction func tapSendChat(_ sender: CustomFilledButton) {
        
        // 텍스트 저장
        let albumDocId = albumRef.documentID
        let email = GlobalUserManager.shared.globalUser?.email
        saveChatMessage(documentId: albumDocId, messageText: chatTextView.text, by: email!)
        
        chatTextView.text = ""
        setButtonOn(button: sendChatButton, isOn: false)
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
