//
//  InviteFriendsViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/19/24.
//

import UIKit

class InviteFriendsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var inviteFriendsTableView: UITableView!
    @IBOutlet weak var searchFriends: CustomSearchBar!

    var loadingIndicator: LoadingIndicator!
    var filteredFriendsList: [UserViewModel] = []
    var sectionTitles = ["즐겨찾기", "친구 목록"]
    var selectedFriends = Set<String>()
    var sendSelectedFriendsList: ((Set<String>, [UserViewModel]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inviteFriendsTableView.delegate = self
        inviteFriendsTableView.dataSource = self
        
        // 로딩 인디케이터 설정
        loadingIndicator = LoadingIndicator(in: self.view)
        loadingIndicator.setupLoadingIndicator()
        
        searchFriends.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 테이블뷰 보이지 않기 (데이터 로딩이 완료되면 보이도록)
        inviteFriendsTableView.isHidden = true
    }
    
    // 텍스트 입력할 때마다 호출
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = searchFriends.text else { return }
        let friendsList = GlobalFriendsManager.shared.globalFriendsList
        if text.isEmpty {
            filteredFriendsList = friendsList
        } else {
            filteredFriendsList = friendsList.filter { $0.userName.localizedCaseInsensitiveContains(text) }
        }
        inviteFriendsTableView.reloadData()
    }
    
    // 테이블 데이터 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendsList = [filteredFriendsList]
        let infoList = [[]] + friendsList
        let sectionItems = infoList[indexPath.section]
        let friendsCell = inviteFriendsTableView.dequeueReusableCell(withIdentifier: "InviteFriendsCell", for: indexPath) as! InviteFriendsCell
        
        // 버튼 상태
        if selectedFriends.contains(sectionItems[indexPath.row].email) {
            friendsCell.setCheckBoxIcon(imageView: friendsCell.checkBox, select: true)
        } else {
            friendsCell.setCheckBoxIcon(imageView: friendsCell.checkBox, select: false)
        }
        
        // 프로필 사진 설정
        if let profilePhoto = sectionItems[indexPath.row].profilePhoto {
            setCustomImage(imageView: friendsCell.profileImage, image: profilePhoto)
        } else {
            setIconImage(imageView: friendsCell.profileImage, color: .weMapSkyBlue, icon: "user-icon")
        }
        friendsCell.profileName.text = sectionItems[indexPath.row].userName
        return friendsCell
    }
    
    // 테이블 데이터 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return filteredFriendsList.count
        }
    }
    
    // 셀 선택 시 실행
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friendsList = [filteredFriendsList]
        let infoList = [[]] + friendsList
        let sectionItems = infoList[indexPath.section]
        let friendsCell = inviteFriendsTableView.dequeueReusableCell(withIdentifier: "InviteFriendsCell", for: indexPath) as! InviteFriendsCell
        
        if selectedFriends.contains(sectionItems[indexPath.row].email) {
            selectedFriends.remove(sectionItems[indexPath.row].email)
            friendsCell.setCheckBoxIcon(imageView: friendsCell.checkBox, select: false)
        } else {
            selectedFriends.insert(sectionItems[indexPath.row].email)
            friendsCell.setCheckBoxIcon(imageView: friendsCell.checkBox, select: true)
        }
        inviteFriendsTableView.reloadData()
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
            filteredFriendsList = GlobalFriendsManager.shared.globalFriendsList
        }
        
        loadingIndicator.OnOffLoadingIndicator(isOn: false)
        inviteFriendsTableView.reloadData()
        inviteFriendsTableView.isHidden = false
        
    }
    
    @IBAction func tapCancelInviteFriends(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 확인 버튼 터치 시
    @IBAction func tapConfirmButton(_ sender: UIButton) {
        var friendsList = GlobalFriendsManager.shared.globalFriendsList
        friendsList = friendsList.filter { selectedFriends.contains($0.email) }
        sendSelectedFriendsList?(selectedFriends, friendsList)
        self.dismiss(animated: true, completion: nil)
    }
    
}
