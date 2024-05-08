//
//  CustomSearchBar.swift
//  WeMap
//
//  Created by Lee Soheun on 4/18/24.
//

import UIKit

class CustomSearchBar: UITextField, UITextFieldDelegate {
    
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
        self.delegate = self
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
    
    // 클리어 버튼을 누르면 키보드가 자동으로 내려가도록 하기
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            textField.endEditing(true)
        }
        return true
    }
    
    // 완료 버튼을 누르면 키보드가 내려가도록 하기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

}
