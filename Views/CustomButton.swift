//
//  CustomButton.swift
//  WeMap
//
//  Created by Lee Soheun on 4/16/24.
//

import UIKit

class CustomFilledButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.weMapBlue
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 10
    }
}

class CustomPlainButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.white
        self.setTitleColor(.weMapBlue, for: .normal)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.weMapBlue.cgColor
        self.layer.cornerRadius = 10
    }
}
