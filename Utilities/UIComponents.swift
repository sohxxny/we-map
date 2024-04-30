//
//  UIComponents.swift
//  WeMap
//
//  Created by Lee Soheun on 4/30/24.
//

import Foundation
import UIKit

// 로딩 인디케이터 클래스
class LoadingIndicator: UIActivityIndicatorView {
    
    weak var containerView: UIView!
    
    init(in containerView: UIView) {
        super.init(style: .medium)
        self.containerView = containerView
        self.center = containerView.center
        containerView.addSubview(self)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    // 로딩 인디케이터 설정
    func setupLoadingIndicator() {
        containerView.addSubview(self)
        OnOffLoadingIndicator(isOn: true)
    }

    // 로딩 인디케이터 켜거나 끄기
    func OnOffLoadingIndicator(isOn: Bool) {
        if isOn {
            self.startAnimating()
            self.isHidden = false
        } else {
            self.stopAnimating()
            self.isHidden = true
        }
    }
}

// 프로필 사진 없을 때의 디폴트 이미지 세팅
func setCustomImage(imageView: UIImageView, color: UIColor, icon: String) {
    if let image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate) {
        imageView.image = image
        imageView.tintColor = color
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
    }
}

// 프로필 사진 없을 때의 디폴트 이미지 세팅
func setCustomImageButton(button: UIButton, color: UIColor, icon: String) {
    if let image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate) {
        button.setImage(image, for: .normal)
        button.tintColor = color
        button.contentMode = .scaleAspectFit
        button.clipsToBounds = true
    }
}
