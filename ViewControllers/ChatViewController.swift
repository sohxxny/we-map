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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var memberInfoList: [AlbumMemberModel] = []
    var chatModelList: [ChatModel] = []
    var sectionIndices: [Int] = []
    var albumRef: DocumentReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTextView.delegate = self
        
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        Task {
            chatModelList = await createChatModelList(documentId: albumRef.documentID, userList: memberInfoList)
            calculateSectionIndex()
            
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            chatTableView.reloadData()
            
            self.view.layoutIfNeeded()
            scrollToBottom()
        }
        
        observeMessages(documentId: albumRef.documentID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if chatTextView.text == "" {
            setButtonOn(button: sendChatButton, isOn: false)
        } else {
            setButtonOn(button: sendChatButton, isOn: true)
        }
        print(chatTableView.contentInset)
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
        if section < sectionIndices.count - 1 {
            return sectionIndices[section + 1] - sectionIndices[section]
        } else {
            return chatModelList.count - sectionIndices[section]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let continuousChatCell = chatTableView.dequeueReusableCell(withIdentifier: "ContinuousChatTableViewCell", for: indexPath) as! ContinuousChatTableViewCell
        let myChatTableViewCell = chatTableView.dequeueReusableCell(withIdentifier: "MyChatTableViewCell", for: indexPath) as! MyChatTableViewCell
        let chatCell = chatTableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        let myInfo = GlobalUserManager.shared.globalUser!
        
        let chatIndex = sectionIndices[indexPath.section] + indexPath.row
        
        if chatModelList[chatIndex].user.email == myInfo.email {
            myChatTableViewCell.chatContent.text = chatModelList[chatIndex].content
            myChatTableViewCell.chatTime.text =  "\(chatModelList[chatIndex].time.dayPeriod.rawValue) \(chatModelList[chatIndex].time.hour):\(chatModelList[chatIndex].time.minute)"
            return myChatTableViewCell
        } else {
            if indexPath.row > 0 && chatModelList[chatIndex].user.email == chatModelList[chatIndex - 1].user.email {
                continuousChatCell.chatContent.text = chatModelList[chatIndex].content
                continuousChatCell.chatTime.text = "\(chatModelList[chatIndex].time.dayPeriod.rawValue) \(chatModelList[chatIndex].time.hour):\(chatModelList[chatIndex].time.minute)"
                return continuousChatCell
            } else {
                chatCell.profileName.text = chatModelList[chatIndex].user.userName
                chatCell.chatContent.text = chatModelList[chatIndex].content
                chatCell.chatTime.text = "\(chatModelList[chatIndex].time.dayPeriod.rawValue) \(chatModelList[chatIndex].time.hour):\(chatModelList[chatIndex].time.minute)"
                if let profilePhoto = chatModelList[chatIndex].user.profilePhoto {
                    setCustomImage(imageView: chatCell.profileImage, image: profilePhoto)
                } else {
                    setIconImage(imageView: chatCell.profileImage, color: .weMapSkyBlue, icon: "user-icon")
                }
                return chatCell
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionIndices.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !chatModelList.isEmpty else { return nil }
        return formattedDate(chatModelList[sectionIndices[section]].time)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // 헤더 타이틀 설정
        let headerView = UIView()
        let headerLabel = UILabel()
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.font = UIFont.systemFont(ofSize: 12)
        headerLabel.backgroundColor = .white
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .center
        headerLabel.textColor = UIColor.lightGray
        
        // 헤더 뷰 생성
        let labelContainer = UIView()
        labelContainer.translatesAutoresizingMaskIntoConstraints = false
        labelContainer.backgroundColor = UIColor.white
        
        // 구분선 설정
        let lineView = UIView()
        lineView.backgroundColor = UIColor.lightGray
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(lineView)
        headerView.addSubview(labelContainer)
        headerView.addSubview(headerLabel)

        // 레이블 제약조건
        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        // 컨테이너 뷰 제약조건
        NSLayoutConstraint.activate([
            labelContainer.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            labelContainer.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor, constant: -10),
            labelContainer.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10),
            labelContainer.heightAnchor.constraint(equalTo: headerLabel.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            lineView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            lineView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            lineView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    // 섹션 시작 번호 저장
    func calculateSectionIndex() {
        guard !chatModelList.isEmpty else {
            sectionIndices = []
            return
        }
        sectionIndices = [0]
        if chatModelList.count != 1 {
            for i in 1..<chatModelList.count {
                if !isSameDate(date1: chatModelList[i].time, date2: chatModelList[i - 1].time) {
                    sectionIndices.append(i)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
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
                    self.calculateSectionIndex()
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
