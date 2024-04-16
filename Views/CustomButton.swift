//
//  CustomButton.swift
//  WeMap
//
//  Created by Lee Soheun on 4/16/24.
//

import UIKit

class CustomButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.weMapBlue
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 10
    }

}
