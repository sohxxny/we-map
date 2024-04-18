//
//  AlertHelper.swift
//  WeMap
//
//  Created by Lee Soheun on 1/29/24.
//

import Foundation
import UIKit

class AlertHelper {
    
    // 버튼 없는 alert
    static func showAlertWithNoButton(on vc: UIViewController, with title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.present(alert, animated: true, completion: nil)
    }
    
    // 확인 버튼만 있는 alert
    static func alertWithConfirmButton(on vc: UIViewController, with title : String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    
}
