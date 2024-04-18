//
//  CustomButton.swift
//  WeMap
//
//  Created by Lee Soheun on 4/16/24.
//

import UIKit

class CustomButton: UIButton {

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
