//
//  MainViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 2/26/24.
//

import UIKit

class MainViewController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var mainMapView: MainMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 지도 화면 터치 시 키보드 내리는 클로저 구현
        mainMapView.onMapsTap = { [weak self] in
                    self?.view.endEditing(true)
                }
    }
    
    // 화면 터치 이벤트 함수
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        // 화면 터치 시 키보드 내리기
        self.view.endEditing(true)
    }

}
