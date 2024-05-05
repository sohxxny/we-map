//
//  NotificationViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/1/24.
//

import UIKit

class NotificationViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var notificationTableView: UITableView!
    
    var notificationModelList: [NotificationModel] = []
    var loadingIndicator: LoadingIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView delegate, dataSource 설정
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        
        // 로딩 인디케이터 설정
        loadingIndicator = LoadingIndicator(in: self.view)
        loadingIndicator.setupLoadingIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // notification 데이터 가져오기
        Task{
            notificationModelList = await GlobalUserManager.shared.fetchNotification()
            updateUI()
        }
        
        // 테이블뷰 보이지 않기 (데이터 로딩이 완료되면 보이도록)
        notificationTableView.isHidden = true
    }
    
    // 테이블 데이터 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationModelList.count
    }
    
    // 테이블 데이터 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationsModel = notificationModelList[indexPath.row]
        
        switch notificationsModel.type {
        // 친구 요청 알림
        case .friendsRequest:
            let friendsRequestCell = notificationTableView.dequeueReusableCell(withIdentifier: "FriendsRequestCell", for: indexPath) as! FriendsRequestTableViewCell
            setIconImage(imageView: friendsRequestCell.friendsRequestUserImage, color: .weMapSkyBlue, icon: "user-icon")
            friendsRequestCell.friendsRequestUserName.text = notificationModelList[indexPath.row].userName
            
            friendsRequestCell.friendsRequestAcceptButton.tag = indexPath.row
            return friendsRequestCell
            
        // 앨범 초대 알림
        case .inviteAlbum:
            let inviteAlbumCell = notificationTableView.dequeueReusableCell(withIdentifier: "inviteAlbumCell", for: indexPath) as! InviteAlbumTableViewCell
            setIconImage(imageView: inviteAlbumCell.inviteAlbumUserImage, color: .weMapSkyBlue, icon: "user-icon")
            inviteAlbumCell.inviteAlbumUserName.text = notificationModelList[indexPath.row].userName
            inviteAlbumCell.inviteAlbumLocation.text = notificationModelList[indexPath.row].location
            return inviteAlbumCell
        }
    }
    
    // UI 업데이트 및 테이블 뷰 보이기
    override func updateUI() {
        super.updateUI()
        loadingIndicator.OnOffLoadingIndicator(isOn: false)
        notificationTableView.reloadData()
        notificationTableView.isHidden = false
    }
    
    @IBAction func tapFriendsRequestAccept(_ sender: CustomFilledButton) {
        let row = sender.tag
        AlertHelper.alertWithTwoButton(on: self, with: nil, message: "친구 요청을 수락하시겠습니까?", completion: {
            self.acceptFriendsRequest(userEmail: self.notificationModelList[row].userEmail, row: row)
        })
    }
    
    @IBAction func tapFriendsRequestReject(_ sender: CustomPlainButton) {
        let row = sender.tag
        AlertHelper.alertWithTwoButton(on: self, with: nil, message: "친구 요청을 거절하시겠습니까?", completion: {
            self.rejectFriendsRequest(userEmail: self.notificationModelList[row].userEmail, row: row)
        })
    }
    
    func acceptFriendsRequest(userEmail: String, row: Int) {
        Task {
            // 서로의 친구 리스트에 추가
            if let userUid = await searchUserByEmail(email: userEmail) {
                await GlobalUserManager.shared.addFriends(firstUserUid: userUid, firstUserEmail: userEmail, secondUserUid: GlobalUserManager.shared.globalUser!.uid, secondUserEmail: GlobalUserManager.shared.globalUser!.email)
            }
            
            // 친구 리스트 다시 불러오기
            if let userInfo = GlobalUserManager.shared.globalUser {
                GlobalFriendsManager.shared.globalFriendsList = await GlobalFriendsManager.shared.getFriendsInfo(userInfo: userInfo)
            }
            
            // 데이터베이스 친구 요청 삭제 및 notificationModel 삭제
            if let userInfo = GlobalUserManager.shared.globalUser {
                await GlobalUserManager.shared.deleteFriendsRequest(senderEmail: userEmail, receiverEmail: userInfo.email, receiverUid: userInfo.uid)
                notificationModelList.remove(at: row)
            }
            
            // 알림 및 테이블 뷰 업데이트
            AlertHelper.showAlertWithNoButton(on: self, with: nil, message: "친구 추가가 완료되었습니다.")
            notificationTableView.reloadData()
        }
    }
    
    func rejectFriendsRequest(userEmail: String, row: Int) {
        Task {
            // 데이터베이스 친구 요청 삭제 및 notificationModel 삭제
            if let userInfo = GlobalUserManager.shared.globalUser {
                await GlobalUserManager.shared.deleteFriendsRequest(senderEmail: userEmail, receiverEmail: userInfo.email, receiverUid: userInfo.uid)
                notificationModelList.remove(at: row)
            }
            
            // 테이블 뷰 업데이트
            notificationTableView.reloadData()
        }
    }
}
