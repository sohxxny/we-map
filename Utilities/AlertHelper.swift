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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    // 확인 버튼만 있는 alert
    static func alertWithConfirmButton(on vc: UIViewController, with title : String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    // 클로저를 받는 alert
    static func alertWithTwoButton(on vc: UIViewController, with title: String?, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) { _ in
            completion()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        vc.present(alert, animated: true, completion: nil)
    }
}
