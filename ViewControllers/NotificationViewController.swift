//
//  NotificationViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/1/24.
//

import UIKit
import FirebaseFirestore

class NotificationViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var emptyNotificationLabel: UILabel!
    
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
        
        emptyNotificationLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 테이블뷰 보이지 않기 (데이터 로딩이 완료되면 보이도록)
        loadingIndicator.OnOffLoadingIndicator(isOn: true)
        notificationTableView.isHidden = true
        
        // notification 데이터 가져오기
        Task{
            notificationModelList = await GlobalUserManager.shared.fetchNotification()
            updateNotification()
            
            if notificationModelList.isEmpty {
                emptyNotificationLabel.isHidden = false
            } else {
                emptyNotificationLabel.isHidden = true
            }
        }
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
            
            if let image = notificationsModel.userImage {
                setCustomImage(imageView: friendsRequestCell.friendsRequestUserImage, image: image)
            } else {
                setIconImage(imageView: friendsRequestCell.friendsRequestUserImage, color: .weMapSkyBlue, icon: "user-icon")
            }
            friendsRequestCell.friendsRequestUserName.text = notificationModelList[indexPath.row].userName
            
            friendsRequestCell.friendsRequestAcceptButton.tag = indexPath.row
            return friendsRequestCell
            
        // 앨범 초대 알림
        case .inviteAlbum:
            let inviteAlbumCell = notificationTableView.dequeueReusableCell(withIdentifier: "InviteAlbumTableViewCell", for: indexPath) as! InviteAlbumTableViewCell
            setIconImage(imageView: inviteAlbumCell.inviteAlbumUserImage, color: .weMapSkyBlue, icon: "user-icon")
            inviteAlbumCell.inviteAlbumUserName.text = notificationModelList[indexPath.row].userName
            inviteAlbumCell.inviteAlbumLocation.text = notificationModelList[indexPath.row].location
            
            if let image = notificationsModel.userImage {
                setCustomImage(imageView: inviteAlbumCell.inviteAlbumUserImage, image: image)
            } else {
                setIconImage(imageView: inviteAlbumCell.inviteAlbumUserImage, color: .weMapSkyBlue, icon: "user-icon")
            }
            
            inviteAlbumCell.inviteAlbumAcceptButton.tag = indexPath.row
            return inviteAlbumCell
        }
    }
    
    // UI 업데이트 및 테이블 뷰 보이기
//    override func updateUI() {
//        super.updateUI()
//        loadingIndicator.OnOffLoadingIndicator(isOn: false)
//        notificationTableView.reloadData()
//        notificationTableView.isHidden = false
//    }
    
    // 테이블 뷰 업데이트
    func updateNotification() {
        loadingIndicator.OnOffLoadingIndicator(isOn: false)
        notificationTableView.reloadData()
        notificationTableView.isHidden = false
    }
    
    @IBAction func tapFriendsRequestAccept(_ sender: CustomFilledButton) {
        let row = sender.tag
        AlertHelper.alertWithTwoButton(on: self, with: nil, message: "친구 요청을 수락하시겠습니까?", completion: {
            self.acceptFriendsRequest(notification: self.notificationModelList[row], row: row)
        })
    }
    
    @IBAction func tapFriendsRequestReject(_ sender: CustomPlainButton) {
        let row = sender.tag
        AlertHelper.alertWithTwoButton(on: self, with: nil, message: "친구 요청을 거절하시겠습니까?", completion: {
            self.rejectFriendsRequest(notification: self.notificationModelList[row], row: row)
        })
    }
    
    func acceptFriendsRequest(notification: NotificationModel, row: Int) {
        Task {
            // 서로의 친구 리스트에 추가
            if let userUid = await searchUserByEmail(email: notification.userEmail) {
                await GlobalUserManager.shared.addFriends(firstUserUid: userUid, firstUserEmail: notification.userEmail, secondUserUid: GlobalUserManager.shared.globalUser!.uid, secondUserEmail: GlobalUserManager.shared.globalUser!.email)
            }
            
            // 친구 리스트 다시 불러오기
            if let userInfo = GlobalUserManager.shared.globalUser {
                GlobalFriendsManager.shared.globalFriendsList = await GlobalFriendsManager.shared.getFriendsInfo(userInfo: userInfo)
            }
            
            // 데이터베이스 친구 요청 삭제 및 notificationModel 삭제
            try await notification.notificationRef.delete()
            notificationModelList.remove(at: row)
            
            // 알림 및 테이블 뷰 업데이트
            AlertHelper.showAlertWithNoButton(on: self, with: nil, message: "친구 추가가 완료되었습니다.")
            notificationTableView.reloadData()
        }
    }
    
    func rejectFriendsRequest(notification: NotificationModel, row: Int) {
        notification.notificationRef.delete()
        notificationModelList.remove(at: row)
        notificationTableView.reloadData()
    }
    
    @IBAction func tapInviteAlbumAccept(_ sender: CustomFilledButton) {
        let row = sender.tag
        AlertHelper.alertWithTwoButton(on: self, with: nil, message: "앨범 초대를 수락하시겠습니까?", completion: {
            self.acceptInviteAlbum(notification: self.notificationModelList[row], row: row)
        })
    }
    
    @IBAction func tapInviteAlbumReject(_ sender: CustomPlainButton) {
        let row = sender.tag
        AlertHelper.alertWithTwoButton(on: self, with: nil, message: "앨범 초대를 거절하시겠습니까?", completion: {
            self.rejectInviteAlbum(notification: self.notificationModelList[row], row: row)
        })
    }
    
    func acceptInviteAlbum(notification: NotificationModel, row: Int) {
        guard let userInfo = GlobalUserManager.shared.globalUser, let albumRef = notification.albumRef else { return }
        
        joinAlbum(albumRef: albumRef, userInfo: userInfo)
        addAlbumRef(albumRef, in: userInfo)
        
        // 파이어베이스 notification 삭제
        notification.notificationRef.delete()
        
        // notificationModel 삭제 및 테이블 뷰 업데이트
        notificationModelList.remove(at: row)
        AlertHelper.showAlertWithNoButton(on: self, with: nil, message: "앨범 초대를 수락했습니다.")
        notificationTableView.reloadData()
    }
    
    func rejectInviteAlbum(notification: NotificationModel, row: Int) {
        // 파이어베이스 notification 삭제
        notification.notificationRef.delete()
        
        // notificationModel 삭제 및 테이블 뷰 업데이트
        notificationModelList.remove(at: row)
        notificationTableView.reloadData()
    }
    
}
