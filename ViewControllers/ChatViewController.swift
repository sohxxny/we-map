//
//  ChatViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/30/24.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase

class ChatViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendChatButton: CustomFilledButton!
    @IBOutlet weak var chatTextView: ChatTextView!
    
    var memberInfoList: [AlbumMemberModel] = []
    var chatModelList: [ChatModel] = []
    var albumRef: DocumentReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        Task {
            chatModelList = await createChatModelList(documentId: albumRef.documentID, userList: memberInfoList)
            chatTableView.reloadData()
        }
        
        observeMessages(documentId: albumRef.documentID)
        scrollToBottom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if chatTextView.text == "" {
            setButtonOn(button: sendChatButton, isOn: false)
        } else {
            setButtonOn(button: sendChatButton, isOn: true)
        }
        scrollToBottom()
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
                if let profilePhoto = chatModelList[indexPath.row].user.profilePhoto {
                    setCustomImage(imageView: chatCell.profileImage, image: profilePhoto)
                } else {
                    setIconImage(imageView: chatCell.profileImage, color: .weMapSkyBlue, icon: "user-icon")
                }
                return chatCell
            }
        }
    }
    
    // 실시간으로 데이터 변경을 감지하는 함수
    func observeMessages(documentId: String) {
        let messagesRef = Database.database().reference(withPath: documentId).queryOrdered(byChild: "timeStamp")
        messagesRef.observe(.childAdded, with: { snapshot in
            if let data = snapshot.value as? [String: Any],
               let text = data["text"] as? String,
               let senderEmail = data["senderEmail"] as? String,
               let timeStamp = data["timeStamp"] as? Int64 {
                let userViewModel = matchUserViewModel(find: senderEmail, in: self.memberInfoList)
                self.chatModelList.append(ChatModel(user: userViewModel, content: text, timeStatmp: timeStamp))
                DispatchQueue.main.async {
                    self.chatTableView.reloadData()
                    self.chatTableView.layoutIfNeeded()
                    self.scrollToBottom()
                }
            }
        })
    }
    
    // 아래로 스크롤을 내리는 함수
    func scrollToBottom() {
        if chatTableView.numberOfSections > 0 {
            let lastSection = chatTableView.numberOfSections - 1
            if chatTableView.numberOfRows(inSection: lastSection) > 0 {
                let lastRowIndexPath = IndexPath(row: chatTableView.numberOfRows(inSection: lastSection) - 1, section: lastSection)
                chatTableView.scrollToRow(at: lastRowIndexPath, at: .bottom, animated: false)
            }
        }
    }
    
    // 특정 길이만큼 스크롤을 내리는 함수
    func scrollTableView(by points: CGFloat) {
        let currentOffset = chatTableView.contentOffset
        let newOffset = CGPoint(x: currentOffset.x, y: currentOffset.y + points)
        chatTableView.setContentOffset(newOffset, animated: false)
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
            UIView.animate(withDuration: 0.3) {
                self.stackViewBottomConstraint.constant = keyboardFrame.height - 20
                self.scrollTableView(by: keyboardFrame.height - 20)
                self.view.layoutIfNeeded()
            }
        }
    }

    // 키보드 숨기기 감지
    @objc func keyboardWillHide(notification: NSNotification) {
        stackViewBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
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
