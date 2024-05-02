//
//  NavigationHelper.swift
//  WeMap
//
//  Created by Lee Soheun on 4/30/24.
//

import Foundation
import UIKit

// 네비게이션 컨트롤러의 백 버튼 설정 함수
func setBackButton(vc: UIViewController) {
    let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: vc, action: nil)
    vc.navigationItem.backBarButtonItem = backBarButtonItem
}

