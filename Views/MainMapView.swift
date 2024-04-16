//
//  MainMapView.swift
//  WeMap
//
//  Created by Lee Soheun on 3/15/24.
//

import UIKit
import NMapsMap

class MainMapView: NMFMapView, NMFMapViewTouchDelegate {
    // onMapsTap 클로저 선언
    var onMapsTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        // NMFMapViewTouchDelegate에 대한 delegate 설정
        self.touchDelegate = self
    }
    
    // 지도를 탭했을 때 호출되는 delegate 메소드
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        // onMapsTap 클로저 호출
        onMapsTap?()
    }
}
