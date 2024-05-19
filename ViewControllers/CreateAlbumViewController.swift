//
//  CreateAlbumViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/18/24.
//

import UIKit

class CreateAlbumViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var inviteFriendsButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var selectedFriendsCollectionView: UICollectionView!
    
    var locationInfo: LocationInfo?
    var selectedFriends = Set<String>()
    var selectedFreindsInfo: [UserViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inviteFriendsButton.layer.cornerRadius = inviteFriendsButton.frame.width / 2
        
        selectedFriendsCollectionView.delegate = self
        selectedFriendsCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        address.text = locationInfo?.address
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFreindsInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let selectedFriendsCell = selectedFriendsCollectionView.dequeueReusableCell(withReuseIdentifier: "SelectedFriendsCell", for: indexPath) as! SelectedFriendsCell

        if let profilePhoto = selectedFreindsInfo[indexPath.row].profilePhoto {
            setCustomImage(imageView: selectedFriendsCell.profileImage, image: profilePhoto)
        } else {
            setIconImage(imageView: selectedFriendsCell.profileImage, color: .weMapSkyBlue, icon: "user-icon")
        }
        selectedFriendsCell.profileName.text = selectedFreindsInfo[indexPath.row].userName
        
        return selectedFriendsCell
    }
    
    // 아이템 터치 시 삭제
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFriends.remove(selectedFreindsInfo[indexPath.row].email)
        selectedFreindsInfo.remove(at: indexPath.row)
        selectedFriendsCollectionView.reloadData()
    }
    
    @IBAction func tapInviteFriends(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let inviteFriendsViewController = storyboard.instantiateViewController(withIdentifier: "InviteFriendsViewController") as? InviteFriendsViewController {
            inviteFriendsViewController.selectedFriends = self.selectedFriends
            inviteFriendsViewController.modalPresentationStyle = .fullScreen
            inviteFriendsViewController.sendSelectedFriendsList = { [weak self] emails, userViewModels in
                guard let strongSelf = self else { return }
                strongSelf.selectedFriends = emails
                strongSelf.selectedFreindsInfo = userViewModels
                strongSelf.selectedFriendsCollectionView.reloadData()
            }
            present(inviteFriendsViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapCloseCreateAlbum(_ sender: CustomPlainButton) {
        NotificationCenter.default.post(name: NSNotification.Name("tapCloseCreateAlbum"), object: nil)
    }
}
