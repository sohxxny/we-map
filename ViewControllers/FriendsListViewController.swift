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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print(userViewModelList)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print(self.userViewModelList)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userViewModelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendsCell = friendsListTableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as! ProfileTableViewCell
        
        // 프로필 사진 없으면 기본 사진 넣기
        if userViewModelList[indexPath.row].profilePhoto == "" {
            if let image = UIImage(named: "user-icon")?.withRenderingMode(.alwaysTemplate) {
                friendsCell.profileImageView.image = image
                friendsCell.profileImageView.tintColor = .weMapBlue
                friendsCell.profileImageView.contentMode = .scaleAspectFit
                friendsCell.profileImageView.clipsToBounds = true
                    }
        }
        
        friendsCell.profileNameLabel.text = userViewModelList[indexPath.row].userName
        friendsCell.profileMessageLabel.text = userViewModelList[indexPath.row].profileMessage
        return friendsCell
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
