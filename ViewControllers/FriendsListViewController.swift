//
//  FriendsListViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 4/7/24.
//

import UIKit

class FriendsListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var friendsListTableView: UITableView!
    @IBOutlet weak var searchFriends: CustomSearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate, dataSource 설정
        friendsListTableView.delegate = self
        friendsListTableView.dataSource = self
        
        // 로딩 인디케이터 설정
        setupLoadingIndicator()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 테이블뷰 보이지 않기
        friendsListTableView.isHidden = true
    }

    // 테이블의 데이터 개수 (내 정보 포함)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let friendsList = GlobalFriendsManager.shared.globalFriendsList
        return friendsList.count + 1
    }
    
    // 테이블 데이터 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myInfo = GlobalFriendsManager.shared.globalMyViewModel
        let friendsList = [myInfo] + GlobalFriendsManager.shared.globalFriendsList
        let friendsCell = friendsListTableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as! ProfileTableViewCell
        
        // 프로필 사진 없으면 기본 사진 넣기
        if friendsList[indexPath.row]?.profilePhoto == "" {
            if let image = UIImage(named: "user-icon")?.withRenderingMode(.alwaysTemplate) {
                friendsCell.profileImageView.image = image
                friendsCell.profileImageView.tintColor = .weMapBlue
                friendsCell.profileImageView.contentMode = .scaleAspectFit
                friendsCell.profileImageView.clipsToBounds = true
                    }
        }
        
        friendsCell.profileNameLabel.text = friendsList[indexPath.row]?.userName
        friendsCell.profileMessageLabel.text = friendsList[indexPath.row]?.profileMessage
        return friendsCell
    }
    
    override func updateUI() {
        super.updateUI()
        friendsListTableView.reloadData()
        friendsListTableView.isHidden = false
    }
    
    // 친구 추가 화면으로 이동하기
    @IBAction func tapGotoAddFriends(_ sender: CustomButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addFriendsViewController = storyboard.instantiateViewController(identifier: "AddFriendsViewController") as? AddFriendsViewController {
            addFriendsViewController.modalPresentationStyle = .overCurrentContext
            addFriendsViewController.modalTransitionStyle = .crossDissolve
            self.present(addFriendsViewController, animated: true, completion: nil)
        }
    }
}
