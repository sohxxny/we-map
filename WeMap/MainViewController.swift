//
//  MainViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 2/26/24.
//

import UIKit

class MainViewController: UIViewController, UITabBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    // 화면 터치 이벤트 함수
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        // 화면 터치 시 키보드 내리기
        self.view.endEditing(true)
    }

}
