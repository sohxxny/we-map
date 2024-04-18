//
//  MainMapView.swift
//  WeMap
//
//  Created by Lee Soheun on 3/15/24.
//

import UIKit
import NMapsMap

class MainMapView: NMFMapView, NMFMapViewTouchDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        // NMFMapViewTouchDelegate에 대한 delegate 설정
        self.touchDelegate = self
    }

}
