//
//  FriendsListViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 4/7/24.
//

import UIKit

class FriendsListViewController: BaseViewController {
    
    @IBOutlet weak var friendsList: UITableView!
    @IBOutlet weak var searchFriends: CustomSearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate, dataSource 설정
//        friendsList.delegate = self
//        friendsList.dataSource = self
        
        // 친구 목록 불러오기
        
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
