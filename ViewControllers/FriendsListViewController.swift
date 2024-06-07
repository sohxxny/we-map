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
    
    var addFriendsViewController: AddFriendsViewController!
    var loadingIndicator: LoadingIndicator!
    var filteredFriendsList: [FriendsModel] = []
    var sectionTitles = ["내 정보", "즐겨찾기", "친구 목록"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView delegate, dataSource 설정
        friendsListTableView.delegate = self
        friendsListTableView.dataSource = self
        
        // 로딩 인디케이터 설정
        loadingIndicator = LoadingIndicator(in: self.view)
        loadingIndicator.setupLoadingIndicator()
        
        // 테이블뷰 보이지 않기 (데이터 로딩이 완료되면 보이도록)
        friendsListTableView.isHidden = true
        
        // 백 버튼 설정 함수
        setBackButton(vc: self)
        
        // 검색 창 입력 감지
        searchFriends.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        addFriendsViewController = storyboard.instantiateViewController(identifier: "AddFriendsViewController") as? AddFriendsViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addFriendsViewController.dismiss(animated: false, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = searchFriends.text else { return }
        let friendsList = GlobalFriendsManager.shared.globalFriendsModelList
        if text.isEmpty {
            filteredFriendsList = friendsList
        } else {
            filteredFriendsList = friendsList.filter { $0.user.userName.localizedCaseInsensitiveContains(text) }
        }
        friendsListTableView.reloadData()
    }
    
    // 테이블 데이터 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myInfo = GlobalFriendsManager.shared.globalMyViewModel
        let friendsList = filteredFriendsList
        let friendsCell = friendsListTableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as! ProfileTableViewCell
        
        if indexPath.section == 0 {
            if let profilePhoto = myInfo?.profilePhoto {
                setCustomImage(imageView: friendsCell.profileImageView, image: profilePhoto)
            } else {
                setIconImage(imageView: friendsCell.profileImageView, color: .weMapSkyBlue, icon: "user-icon")
            }
            friendsCell.profileNameLabel.text = myInfo?.userName
            friendsCell.profileMessageLabel.text = myInfo?.profileMessage
        } else {
            let friends = (indexPath.section == 1) ? friendsList.filter { $0.isBookMarked }[indexPath.row] : friendsList[indexPath.row]
            if let profilePhoto = friends.user.profilePhoto {
                setCustomImage(imageView: friendsCell.profileImageView, image: profilePhoto)
            } else {
                setIconImage(imageView: friendsCell.profileImageView, color: .weMapSkyBlue, icon: "user-icon")
            }
            
            // 이름, 프로필 메시지 넣기
            friendsCell.profileNameLabel.text = friends.user.userName
            friendsCell.profileMessageLabel.text = friends.user.profileMessage
        }
        
        return friendsCell
    }
    
    // 셀 클릭 시 동작하는 함수
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        friendsListTableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            self.performSegue(withIdentifier: "showMyPage", sender: self)
        } else {
            self.performSegue(withIdentifier: "showFriendsPage", sender: indexPath)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFriendsPage" {
            if let friendPage = segue.destination as? MyFriendsPageViewController, let indexPath = sender as? IndexPath {
                if indexPath.section == 1 {
                    let friendInfo = filteredFriendsList.filter { $0.isBookMarked }[indexPath.row]
                    friendPage.friendInfo = friendInfo
                } else {
                    let friendInfo = filteredFriendsList[indexPath.row]
                    friendPage.friendInfo = friendInfo
                }
            }
        }
    }
    
    // 테이블의 데이터 개수 (내 정보 포함)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return filteredFriendsList.filter { $0.isBookMarked }.count
        } else {
            return filteredFriendsList.count
        }
    }
    
    // 섹션 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    // 섹션 타이틀 지정 (헤더)
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    // 헤더 높이 지정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    // 섹션 footer에 구분선 추가
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        // 마지막 섹션의 푸터는 보이지 않기
        if section == tableView.numberOfSections - 1 {
            return nil
        }
        
        // 구분선 설정
        let padding = 10.0
        let footerView = UIView(frame: CGRect(x: padding, y: 0, width: tableView.bounds.width - padding * 2, height: 0.7))
        let layer = CALayer()
        layer.frame = CGRect(x: padding, y: 12, width: footerView.frame.width, height: 0.7)
        layer.backgroundColor = UIColor.systemGray5.cgColor
        footerView.layer.addSublayer(layer)
        
        return footerView
    }
    
    // footer 높이 지정
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25
    }
    
    // UI 업데이트 및 테이블 뷰 보이기
    override func updateUI() {
        super.updateUI()
        
        // 데이터가 다 불러와지면 friendsList에 데이터 넣기
        if searchFriends.text == "" {
            filteredFriendsList = GlobalFriendsManager.shared.globalFriendsModelList
        }
        
        loadingIndicator.OnOffLoadingIndicator(isOn: false)
        friendsListTableView.reloadData()
        friendsListTableView.isHidden = false
    }
    
    // 친구 추가 화면으로 이동하기
    @IBAction func tapGotoAddFriends(_ sender: UIButton) {
        addFriendsViewController.modalPresentationStyle = .overCurrentContext
        addFriendsViewController.modalTransitionStyle = .crossDissolve
        self.present(addFriendsViewController, animated: true, completion: nil)
    }
}
