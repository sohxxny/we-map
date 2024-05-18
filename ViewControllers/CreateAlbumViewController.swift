//
//  CreateAlbumViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/18/24.
//

import UIKit

class CreateAlbumViewController: UIViewController {
    
    @IBOutlet weak var inviteFriendsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inviteFriendsButton.layer.cornerRadius = inviteFriendsButton.frame.width / 2

    }
    

}
