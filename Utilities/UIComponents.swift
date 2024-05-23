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

// 아이콘 이미지
func setIconImage(imageView: UIImageView, color: UIColor, icon: String) {
    if let image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate) {
        imageView.image = image
        imageView.tintColor = color
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
    }
}

// 아이콘 이미지 버튼
func setIconImageButton(button: UIButton, color: UIColor, icon: String) {
    if let image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate) {
        button.setImage(image, for: .normal)
        button.tintColor = color
        button.contentMode = .scaleAspectFit
        button.clipsToBounds = true
    }
}

// 이미지 경로를 받아 이미지뷰에 적용
func setCustomImage(imageView: UIImageView, image: UIImage) {
    imageView.image = image
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
}

// 이미지 경로를 받아 이미지뷰에 적용
func setCustomImageButton(button: UIButton, image: UIImage) {
    button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
    button.imageView?.contentMode = .scaleAspectFill
    button.clipsToBounds = true
}

// UICollectionView 레이아웃을 설정하는 함수
func setupCollectionViewLayout(for collectionView: UICollectionView, itemsPerRow: CGFloat, spacing: CGFloat, sectionInset: CGFloat, isSquare: Bool = true) {
    let layout = UICollectionViewFlowLayout()
    let totalSpacing = (itemsPerRow - 1) * spacing
    let itemWidth = (collectionView.bounds.width - totalSpacing - sectionInset * 2) / itemsPerRow
    let itemHeight: CGFloat = isSquare ? itemWidth : itemWidth + 30
    layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    layout.minimumInteritemSpacing = spacing
    layout.minimumLineSpacing = spacing
    layout.sectionInset = UIEdgeInsets(top: sectionInset, left: sectionInset, bottom: sectionInset, right: sectionInset)

    collectionView.setCollectionViewLayout(layout, animated: true)
}
