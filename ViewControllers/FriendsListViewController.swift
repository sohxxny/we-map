//
//  FriendsListViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 4/7/24.
//

import UIKit

class FriendsListViewController: UIViewController {
    
    @IBOutlet weak var friendsList: UITableView!
    @IBOutlet weak var searchFriends: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 검색창 선 없애기
        searchFriends?.searchBarStyle = .minimal
        
        // delegate, dataSource 설정
//        friendsList.delegate = self
//        friendsList.dataSource = self
        
        // 친구 목록 불러오기
        
    }

}
