//
//  GlobalViewManager.swift
//  WeMap
//
//  Created by Lee Soheun on 4/14/24.
//

import Foundation
import UIKit

// 지도를 전역적으로 관리하기 위한 싱글톤 클래스
class GlobalMapsManager {
    
    static let shared = GlobalMapsManager() // 싱글톤 인스턴스
    private(set) var globalMaps: MainMapView?    // 전역으로 사용될 지도

    // 초기화 방지
    private init() {}

    // 뷰 가져오기 또는 생성하기
    func getOrCreateView() -> MainMapView {
        if let view = globalMaps {
            return view
        } else {
            let newView = createMapView()
            globalMaps = newView
            return newView
        }
    }
    
    // 지도 생성
    func createMapView() -> MainMapView {
        let mainMapView = MainMapView()
        return mainMapView
    }
}

// 검색 버튼을 전역적으로 관리하기 위한 싱글톤 클래스
class GlobalSearchButtonManager {
    
    static let shared = GlobalSearchButtonManager()
    private(set) var globalSearchButton: UIButton?
    
    private init() {}
    
    // 뷰 가져오기 또는 생성하기
    func getOrCreateButton(target: Any, action: Selector) -> UIButton {
        if let searchButton = globalSearchButton {
            return searchButton
        } else {
            let newButton = createSearchButton(target: target, action: action)
            globalSearchButton = newButton
            return newButton
        }
    }
    
    // 검색창 버튼 생성
    func createSearchButton(target: Any, action: Selector) -> UIButton {
        
        var config = UIButton.Configuration.plain()
        var titleFont = AttributedString.init("친구와 공유할 장소를 검색하세요")
        titleFont.font = .systemFont(ofSize: 15)
        config.attributedTitle = titleFont
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
        config.titleAlignment = .leading
        
        let searchButton = UIButton(configuration: config, primaryAction: nil)
        
        searchButton.backgroundColor = UIColor.white
        searchButton.tintColor = UIColor.systemGray3
        searchButton.addTarget(target, action: action, for: .touchUpInside)
        return searchButton
    }
    
}
