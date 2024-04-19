//
//  FriendsListViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 4/7/24.
//

import UIKit

class FriendsListViewController: BaseViewController {
    
    @IBOutlet weak var friendsList: UITableView!
    @IBOutlet weak var searchFriends: CustomSearchBar!
    
    var backGroundView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 터치 제스쳐 입력받기
        getGesture()
        
        // delegate, dataSource 설정
//        friendsList.delegate = self
//        friendsList.dataSource = self
        
        // 친구 목록 불러오기
        
    }
    
    // 친구 추가 화면으로 이동하기
    @IBAction func tapGotoAddFriends(_ sender: CustomButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addFriendsViewController = storyboard.instantiateViewController(identifier: "AddFriendsViewController") as? AddFriendsViewController {
            
            addFriendsViewController.modalPresentationStyle = .overCurrentContext
            addFriendsViewController.modalTransitionStyle = .crossDissolve
            fadeIn()
            present(addFriendsViewController, animated: true, completion: nil)
        }
    }
    
    // 뒷 화면 Fade In (반투명 배경 설정)
    func fadeIn() {
        backGroundView = UIView(frame: self.view.bounds)
        backGroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        backGroundView?.alpha = 0.0  // 초기 투명도 0으로 설정
        self.view.addSubview(backGroundView!)
        
        // 애니메이션 설정
        UIView.animate(withDuration: 0.3) {
            self.backGroundView?.alpha = 1.0
        }
    }
    
    // 화면 터치 핸들 함수 (팝업이 떠 있는 경우 내리기)
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("배경화면 탭")
        if isPopUpPresented() {
            if let popUp = self.presentedViewController {
                popUp.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // 현재 팝업이 떠있는지 판별하는 함수
    func isPopUpPresented() -> Bool {
        if let _ = self.presentedViewController {
            return true
        } else {
            return false
        }
    }
    
    // 제스처 입력 받기
    func getGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
}
