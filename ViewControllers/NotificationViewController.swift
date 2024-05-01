//
//  NotificationViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/1/24.
//

import UIKit

class NotificationViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var notificationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView delegate, dataSource 설정
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
    }
    
    // 테이블 데이터 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // 테이블 데이터 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationCell = notificationTableView.dequeueReusableCell(withIdentifier: "FriendsRequestCell", for: indexPath) as! FriendsRequestTableViewCell
        
        setCustomImage(imageView: notificationCell.friendsRequestUserImage, color: .weMapSkyBlue, icon: "user-icon")
        notificationCell.friendsRequestUserName.text = "무지무지하게긴이름"
        
        return notificationCell
    }

}
