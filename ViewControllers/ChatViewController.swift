//
//  ChatViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/30/24.
//

import UIKit

class ChatViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chatTableView: UITableView!
    
    let dataList: [[String]] = [["김성규", "안녕ㅋㅋ"], ["김태연", "아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주아주긴메시지ㅋㅋ"], ["김태연", "헤헤"], ["이소흔", "해햇"], ["이소흔", "매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우매우긴채팅ㅋㅋ"]]

    override func viewDidLoad() {
        super.viewDidLoad()

        chatTableView.delegate = self
        chatTableView.dataSource = self

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
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
