//
//  MainMapView.swift
//  WeMap
//
//  Created by Lee Soheun on 3/15/24.
//

import UIKit
import NMapsMap
import CoreLocation

class MainMapView: NMFNaverMapView, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        configureLocationManager()
        mapSetting()
    }
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        DispatchQueue.global().async { [self] in
            if CLLocationManager.locationServicesEnabled() {
                locationManager.requestWhenInUseAuthorization()
                // 위치 서비스가 활성화되어 있으면 위치 업데이트 시작
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latLng = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            self.mapView.moveCamera(NMFCameraUpdate(scrollTo: latLng))
            let locationOverlay = self.mapView.locationOverlay
            locationOverlay.location = latLng
            locationOverlay.hidden = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("위치 권한이 없음")
        }
    }
    
    func mapSetting() {
        // 나침반, 줌 버튼, 현위치 버튼 추가
        self.showZoomControls = true
        self.showLocationButton = true
        
        // 포지션 모드 설정
        self.mapView.positionMode = .direction
        self.mapView.locationOverlay.hidden = false
    }

}
