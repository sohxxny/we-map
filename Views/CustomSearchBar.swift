//
//  CustomSearchBar.swift
//  WeMap
//
//  Created by Lee Soheun on 4/18/24.
//

import UIKit

class CustomSearchBar: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        
        // 기타 UI 설정
        self.backgroundColor = UIColor.systemGray6
        self.layer.cornerRadius = 10
        
        // 아이콘 세팅
        setIcon()
        
        // 글자 지우기 버튼
        self.clearButtonMode = .whileEditing
    }
    
    // 돋보기 아이콘 설정
    func setIcon() {
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: self.frame.height))
        let iconImageView = UIImageView(image: UIImage(systemName: "magnifyingglass")?.withTintColor(.gray, renderingMode: .alwaysOriginal))
        iconImageView.contentMode = .center
        iconImageView.frame = CGRect(x: 0, y: 0, width: 40, height: self.frame.height)
        leftPaddingView.addSubview(iconImageView)

        self.leftView = leftPaddingView
        self.leftViewMode = .always // 아이콘이 항상 보이도록 설정
    }

}
