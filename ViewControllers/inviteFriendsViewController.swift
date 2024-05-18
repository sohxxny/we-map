//
//  inviteFriendsViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/18/24.
//

import UIKit

class inviteFriendsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var inviteFriendsTableView: UITableView!
    
    var loadingIndicator: LoadingIndicator!
    var friendsList: [UserViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inviteFriendsTableView.delegate = self
        inviteFriendsTableView.dataSource = self
        
        // 로딩 인디케이터 설정
        loadingIndicator = LoadingIndicator(in: self.view)
        loadingIndicator.setupLoadingIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        inviteFriendsTableView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let friendsCell = inviteFriendsTableView.dequeueReusableCell(withIdentifier: "InviteFriendsCell", for: indexPath) as! InviteFriendsCell
            
            // 프로필 사진 없으면 기본 사진 넣기
            if let profilePhoto = friendsList[indexPath.row].profilePhoto {
                setCustomImage(imageView: friendsCell.profileImage, image: profilePhoto)
            } else {
                setIconImage(imageView: friendsCell.profileImage, color: .weMapSkyBlue, icon: "user-icon")
            }
            friendsCell.profileName.text = friendsList[indexPath.row].userName
            return friendsCell
    }
    
    // UI 업데이트 및 테이블 뷰 보이기
    override func updateUI() {
        super.updateUI()
        
        loadingIndicator.OnOffLoadingIndicator(isOn: false)
        inviteFriendsTableView.reloadData()
        inviteFriendsTableView.isHidden = false
        
        friendsList = GlobalFriendsManager.shared.globalFriendsList
    }

}
