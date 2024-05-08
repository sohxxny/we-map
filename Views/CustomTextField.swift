//
//  CustomTextField.swift
//  WeMap
//
//  Created by Lee Soheun on 4/16/24.
//

import UIKit

class CustomTextField: UITextField, UITextFieldDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        
        self.delegate = self
        
        // 왼쪽 여백 관련 설정
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.frame.height))
        self.leftView = leftPaddingView
        self.leftViewMode = ViewMode.always
        
        // 기타 UI 설정
        self.layer.cornerRadius = 10
    }
    
    // 완료 버튼을 누르면 키보드가 내려가도록 하기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

}
