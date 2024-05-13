//
//  SettingViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/6/24.
//

import UIKit
import FirebaseAuth

class SettingViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var settingTableView: UITableView!
    
    let settingTitle = ["프로필 수정", "로그아웃"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTableView.delegate = self
        settingTableView.dataSource = self
        
        // 백 버튼 설정 함수
        setBackButton(vc: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingCell = settingTableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        
        settingCell.settingType.text = settingTitle[indexPath.row]
        
        if settingTitle[indexPath.row] == "로그아웃" {
            settingCell.settingType.textColor = .red
        }
        
        return settingCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingTableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "showEditProfile", sender: self)
        } else {
            AlertHelper.alertWithTwoButton(on: self, with: nil, message: "로그아웃하시겠습니까?", completion: {
                self.logOut()
            })
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            print("로그아웃 성공")
            GlobalUserManager.shared.globalUser = nil
            GlobalFriendsManager.shared.globalMyViewModel = nil
            GlobalFriendsManager.shared.globalFriendsList = []
            
            // 미리 홈 화면으로 이동
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let homeViewController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController")
                sceneDelegate.window?.rootViewController = homeViewController
                
                // 모든 모달 제거
            }
            
        } catch let signOutError as NSError {
            print("로그아웃 에러: ", signOutError)
        }
    }

}
