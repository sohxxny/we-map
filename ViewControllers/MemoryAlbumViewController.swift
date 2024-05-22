//
//  MemoryAlbumViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/22/24.
//

import UIKit

class MemoryAlbumViewController: BaseViewController {
    
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var albumSettingButton: UIButton!
    @IBOutlet weak var lastChatView: UIView!
    @IBOutlet weak var lastChatLabel: UILabel!
    
    @IBOutlet weak var numberOfMember: UILabel!
    @IBOutlet weak var numberOfPhoto: UILabel!
    @IBOutlet weak var numberOfVideo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lastChatView.layer.cornerRadius = 10
        lastChatLabel.text = "아주아주아주아주긴채팅ㅋㅋ아주아주아주아주긴채팅ㅋㅋ아주아주아주아주긴채팅ㅋㅋ아주아주아주아주긴채팅ㅋㅋ아주아주아주아주긴채팅ㅋㅋ아주아주아주아주긴채팅ㅋㅋ아주아주아주아주긴채팅ㅋㅋ아주아주아주아주긴채팅ㅋㅋ"
    }

}
