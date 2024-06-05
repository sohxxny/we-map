//
//  CreateAlbumViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/18/24.
//

import UIKit
import Firebase
import FirebaseFirestore

class CreateAlbumViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var inviteFriendsButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var selectedFriendsCollectionView: UICollectionView!
    @IBOutlet weak var albumName: CustomTextField!
    @IBOutlet weak var albumNameLength: UILabel!
    
    var locationInfo: LocationInfo?
    var selectedFriends = Set<String>()
    var selectedFriendsInfo: [FriendsModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inviteFriendsButton.layer.cornerRadius = inviteFriendsButton.frame.width / 2
        
        selectedFriendsCollectionView.delegate = self
        selectedFriendsCollectionView.dataSource = self
        
        albumName.clearButtonMode = .whileEditing
        albumName.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        address.text = locationInfo?.address
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let name = albumName.text else { return }
                
        // 글자 세기
        albumNameLength.text = (name.count > maxAlbumNameLength ? "\(maxAlbumNameLength)" : "\(name.count)") +  " / \(maxAlbumNameLength)"
        
        // 글자 제한
        if name.count > maxAlbumNameLength {
            albumName.text = String(name.prefix(maxAlbumNameLength))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFriendsInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let selectedFriendsCell = selectedFriendsCollectionView.dequeueReusableCell(withReuseIdentifier: "SelectedFriendsCell", for: indexPath) as! SelectedFriendsCell

        if let profilePhoto = selectedFriendsInfo[indexPath.row].user.profilePhoto {
            setCustomImage(imageView: selectedFriendsCell.profileImage, image: profilePhoto)
        } else {
            setIconImage(imageView: selectedFriendsCell.profileImage, color: .weMapSkyBlue, icon: "user-icon")
        }
        selectedFriendsCell.profileName.text = selectedFriendsInfo[indexPath.row].user.userName
        
        return selectedFriendsCell
    }
    
    // 아이템 터치 시 삭제
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFriends.remove(selectedFriendsInfo[indexPath.row].user.email)
        selectedFriendsInfo.remove(at: indexPath.row)
        selectedFriendsCollectionView.reloadData()
    }
    
    // 친구 초대 화면으로 가는 버튼
    @IBAction func tapInviteFriends(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let inviteFriendsViewController = storyboard.instantiateViewController(withIdentifier: "InviteFriendsViewController") as? InviteFriendsViewController {
            inviteFriendsViewController.selectedFriends = self.selectedFriends
            inviteFriendsViewController.modalPresentationStyle = .fullScreen
            inviteFriendsViewController.sendSelectedFriendsList = { [weak self] emails, userFriendsModels in
                guard let strongSelf = self else { return }
                strongSelf.selectedFriends = emails
                strongSelf.selectedFriendsInfo = userFriendsModels
                strongSelf.selectedFriendsCollectionView.reloadData()
            }
            present(inviteFriendsViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapCreateAlbum(_ sender: CustomFilledButton) {
        guard let albumName = albumName.text, let locationInfo = locationInfo else { return }
        if albumName.isEmpty {
            AlertHelper.alertWithConfirmButton(on: self, with: nil, message: "앨범 이름을 입력해주세요.")
            return
        }
        
        createMemoryAlbum(albumName: albumName, location: locationInfo)
    }
    
    // 앨범을 데이터베이스에 생성하는 함수
    func createMemoryAlbum(albumName: String, location: LocationInfo) {
        guard let userInfo = GlobalUserManager.shared.globalUser else { return }
        
        // 날짜 형식 지정
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: datePicker.date)
        
        // 문서 생성
        let db = Firestore.firestore()
        let albumRef = db.collection("memoryAlbum").document()
        
        // 문서의 필드에 날짜, 앨범이름, 좌표 넣기
        albumRef.setData([
            "date": dateString,
            "albumName": albumName,
            "address": location.address,
            "coordinate": GeoPoint(latitude: (location.coordinate.1), longitude: (location.coordinate.0)),
            "timeStamp" : FieldValue.serverTimestamp()
        ])
        
        // 멤버 생성 (나, 초대 친구들)
        let memberRef = albumRef.collection("member").document(userInfo.email)
        memberRef.setData([
            "uid": userInfo.uid,
            "isJoined": true
        ])
        for friend in selectedFriendsInfo {
            let memeberFriendsRef = albumRef.collection("member").document(friend.user.email)
            memeberFriendsRef.setData([
                "uid": friend.user.uid,
                "isJoined": false
            ])
        }
        
        // 내 정보에 앨범 참조 저장, 친구 초대
        addAlbumRef(albumRef, in: userInfo)
        inviteAlbumToFriends(selectedFriendsInfo, albumRef: albumRef, albumName: albumName)
        
        AlertHelper.showAlertWithNoButton(on: self, with: nil, message: "추억 앨범 생성이 완료되었습니다.")
        NotificationCenter.default.post(name: NSNotification.Name("createAlbum"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("tapCloseLocationDetails"), object: nil)
    }
    
    // 앨범에 친구 초대 알림 발송
    func inviteAlbumToFriends(_ friendsList: [FriendsModel], albumRef: DocumentReference, albumName: String) {
        guard let userInfo = GlobalUserManager.shared.globalUser else { return }
        let db = Firestore.firestore()
        for friend in friendsList {
            let ref = db.collection("userInfo").document(friend.user.uid).collection("notification").document()
            ref.setData([
                "type": "inviteAlbum",
                "userEmail": userInfo.email,
                "albumName": albumName,
                "albumRef": albumRef,
                "notificationRef": ref
            ])
        }
    }
    
    // 닫기 버튼
    @IBAction func tapCloseCreateAlbum(_ sender: CustomPlainButton) {
        NotificationCenter.default.post(name: NSNotification.Name("tapCloseCreateAlbum"), object: nil)
    }
}
