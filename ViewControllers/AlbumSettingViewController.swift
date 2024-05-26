//
//  AlbumSettingViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/26/24.
//

import UIKit

class AlbumSettingViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var albumSettingTableView: UITableView!
    
    let settingTitle = ["친구 초대", "앨범 나가기", "앨범 삭제"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        albumSettingTableView.delegate = self
        albumSettingTableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let albumSettingTableViewCell = albumSettingTableView.dequeueReusableCell(withIdentifier: "AlbumSettingTableViewCell", for: indexPath) as! AlbumSettingTableViewCell
        
        albumSettingTableViewCell.settingType.text = settingTitle[indexPath.row]
        
        if indexPath.row == 1 || indexPath.row == 2 {
            albumSettingTableViewCell.settingType.textColor = .red
        }
        
        return albumSettingTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // 친구 초대 화면 이동 로직
        } else if indexPath.row == 1 {
            // 앨범 나가기 로직
            // 나 혼자 뿐이면 삭제랑 같은 함수
        } else {
            // 앨범 삭제 로직
        }
    }
    
    func deleteAlbum() {
        // 앨범 데이터 삭제
        // 앨범 구성원 데이터 삭제
        // 앨범 삭제
    }

    @IBAction func tapBackButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
