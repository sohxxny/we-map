//
//  CustomTextField.swift
//  WeMap
//
//  Created by Lee Soheun on 4/16/24.
//

import UIKit

class CustomTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        
        // 왼쪽 여백 관련 설정
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.frame.height))
        self.leftView = leftPaddingView
        self.leftViewMode = ViewMode.always
        
        // 기타 UI 설정
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 10
    }

}
