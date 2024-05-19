//
//  CreateAlbumViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/18/24.
//

import UIKit

class CreateAlbumViewController: BaseViewController {
    
    @IBOutlet weak var inviteFriendsButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var address: UILabel!
    
    var locationInfo: LocationInfo?
    var selectedFriends: [UserViewModel] = []
    var selectedCells = Set<IndexPath>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inviteFriendsButton.layer.cornerRadius = inviteFriendsButton.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        address.text = locationInfo?.address
    }
    
    @IBAction func tapInviteFriends(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let inviteFriendsViewController = storyboard.instantiateViewController(withIdentifier: "InviteFriendsViewController") as? InviteFriendsViewController {
            inviteFriendsViewController.modalPresentationStyle = .fullScreen
            inviteFriendsViewController.sendSelectedFriendsList = { [weak self] data, cells in
                print(data)
                self?.selectedCells = cells
                self?.selectedFriends = data
            }
            inviteFriendsViewController.selectedCells = self.selectedCells
            self.present(inviteFriendsViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapCloseCreateAlbum(_ sender: CustomPlainButton) {
        NotificationCenter.default.post(name: NSNotification.Name("tapCloseCreateAlbum"), object: nil)
    }
}
