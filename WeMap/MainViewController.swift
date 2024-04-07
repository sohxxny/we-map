//
//  MainViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 2/26/24.
//

import UIKit

class MainViewController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var mainMapView: MainMapView!
    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 탭 바 객체 딜리게이트 설정
        tabBar.delegate = self
        
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
    
    // 탭 바에서 아이템 선택 시 해당 화면으로 이동
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        switch item.tag {
//        case 0:
//            <#code#>
//        case 1:
//            <#code#>
//        case 2:
//            <#code#>
//        case 3:
//            <#code#>
//        case 4:
//            <#code#>
//        default:
//            break
//            
//        }
    }

}
