//
//  MainTabBarController.swift
//  WeMap
//
//  Created by Lee Soheun on 4/9/24.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.delegate = self
        self.delegate = self
        
        // 'HomeViewController'가 디폴트 탭으로 설정
        self.selectedIndex = 2

    }
    
}
