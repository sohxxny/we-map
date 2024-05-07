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
    
    var loadingIndicator: LoadingIndicator!
    var sectionTitles = ["내 정보", "내 친구 목록"]
    var filteredFriendsList: [UserViewModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView delegate, dataSource 설정
        friendsListTableView.delegate = self
        friendsListTableView.dataSource = self
        
        // 로딩 인디케이터 설정
        loadingIndicator = LoadingIndicator(in: self.view)
        loadingIndicator.setupLoadingIndicator()
        
        // 백 버튼 설정 함수
        setBackButton(vc: self)
        
        // 검색 창 입력 감지
        searchFriends.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if searchFriends.text == "" {
            filteredFriendsList = GlobalFriendsManager.shared.globalFriendsList
        }
        
        // 테이블뷰 보이지 않기 (데이터 로딩이 완료되면 보이도록)
        friendsListTableView.isHidden = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = searchFriends.text else { return }
        let friendsList = GlobalFriendsManager.shared.globalFriendsList
        if text.isEmpty {
            filteredFriendsList = friendsList
        } else {
            filteredFriendsList = friendsList.filter { $0.userName.localizedCaseInsensitiveContains(text) }
        }
        friendsListTableView.reloadData()
    }
    
    // 테이블 데이터 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myInfo = [[GlobalFriendsManager.shared.globalMyViewModel]]
        let friendsList = [filteredFriendsList!]
        let infoList = myInfo + friendsList
        let friendsCell = friendsListTableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as! ProfileTableViewCell
        
        // 프로필 사진 없으면 기본 사진 넣기
        if let profilePhoto = infoList[indexPath.section][indexPath.row]?.profilePhoto {
            setCustomImage(imageView: friendsCell.profileImageView, image: profilePhoto)
        } else {
            setIconImage(imageView: friendsCell.profileImageView, color: .weMapSkyBlue, icon: "user-icon")
        }
        
        // 이름, 프로필 메시지 넣기
        friendsCell.profileNameLabel.text = infoList[indexPath.section][indexPath.row]?.userName
        friendsCell.profileMessageLabel.text = infoList[indexPath.section][indexPath.row]?.profileMessage
        return friendsCell
    }
    
    // 셀 클릭 시 동작하는 함수
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        friendsListTableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            self.performSegue(withIdentifier: "showMyPage", sender: self)
        }
    }
    
    // 테이블의 데이터 개수 (내 정보 포함)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let friendsList = filteredFriendsList
        if section == 0 {
            return 1
        } else {
            return friendsList!.count
        }
    }
    
    // 섹션 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
        layer.frame = CGRect(x: padding, y: 7, width: footerView.frame.width, height: 0.7)
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
        loadingIndicator.OnOffLoadingIndicator(isOn: false)
        friendsListTableView.reloadData()
        friendsListTableView.isHidden = false
    }
    
    // 친구 추가 화면으로 이동하기
    @IBAction func tapGotoAddFriends(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addFriendsViewController = storyboard.instantiateViewController(identifier: "AddFriendsViewController") as? AddFriendsViewController {
            addFriendsViewController.modalPresentationStyle = .overCurrentContext
            addFriendsViewController.modalTransitionStyle = .crossDissolve
            self.present(addFriendsViewController, animated: true, completion: nil)
        }
    }
}
