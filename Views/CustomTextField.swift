//
//  CustomTextField.swift
//  WeMap
//
//  Created by Lee Soheun on 4/16/24.
//

import UIKit

class CustomTextField: UITextField {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        
        // placeholder 관련 설정
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.frame.height))
        self.leftView = leftPaddingView
        self.leftViewMode = ViewMode.always
        
        // 기타 UI 설정
        self.layer.cornerRadius = 10
    }

}
