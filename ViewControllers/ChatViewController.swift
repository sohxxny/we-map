//
//  ChatViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/30/24.
//

import UIKit

class ChatViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendChatButton: CustomFilledButton!
    @IBOutlet weak var chatTextView: ChatTextView!
    
    let dataList: [[String]] = [["김성규", "안녕ㅋㅋ"], ["김태연", "아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주긴메시지ㅋㅋ"], ["김태연", "헤헤"], ["이소흔", "해햇"], ["이소흔", "매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우긴채팅ㅋㅋ"]]

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
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 2 {
            let continuousChatCell = chatTableView.dequeueReusableCell(withIdentifier: "ContinuousChatTableViewCell", for: indexPath) as! ContinuousChatTableViewCell
            continuousChatCell.chatContent.text = dataList[indexPath.row][1]
            return continuousChatCell
        } else if indexPath.row > 2 {
            let myChatTableViewCell = chatTableView.dequeueReusableCell(withIdentifier: "MyChatTableViewCell", for: indexPath) as! MyChatTableViewCell
            myChatTableViewCell.chatContent.text = dataList[indexPath.row][1]
            return myChatTableViewCell
        } else {
            let chatCell = chatTableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
            chatCell.profileName.text = dataList[indexPath.row][0]
            chatCell.chatContent.text = dataList[indexPath.row][1]
            setIconImage(imageView: chatCell.profileImage, color: .weMapSkyBlue, icon: "user-icon")
            return chatCell
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            stackViewBottomConstraint.constant = keyboardFrame.height - 20
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        stackViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: sendChatButton) {
            return false
        }
        return super.gestureRecognizer(gestureRecognizer, shouldReceive: touch)
    }
    
    @IBAction func tapSendChat(_ sender: CustomFilledButton) {
        chatTextView.text = ""
        setButtonOn(button: sendChatButton, isOn: false)
        // 텍스트 저장
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
