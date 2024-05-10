//
//  MainMapView.swift
//  WeMap
//
//  Created by Lee Soheun on 3/15/24.
//

import UIKit
import NMapsMap
import CoreLocation

class MainMapView: NMFNaverMapView, CLLocationManagerDelegate, NMFMapViewTouchDelegate {
    
    var locationManager: CLLocationManager!
    var compassButton: NMFCompassView!
    var locationOverlay: NMFLocationOverlay!
    var currentLocation: CLLocation?
    
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
        self.mapView.touchDelegate = self
        configureLocationManager()
        mapSetting()
        setCompassButton()
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
    
    // 위치가 업데이트 될 때마다 호출
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            // 현재 위치 저장
            currentLocation = location
        }
    }
    
    // 지도가 탭 될 때마다 호출
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        getAddressByCoordinates(latitude: latlng.lat, longitude: latlng.lng)
    }
    
    // 위치 권한 설정
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("위치 권한이 없음")
        }
    }
    
    // 컨트롤 추가
    func mapSetting() {
        self.showZoomControls = true
        self.showLocationButton = true
        self.showCompass = false
        self.mapView.positionMode = .direction
    }
    
    // 나침반 버튼 설정
    func setCompassButton() {
        compassButton = NMFCompassView()
        if let compass = compassButton {
            compass.mapView = self.mapView
            let compassSize: CGFloat = 40
            compass.frame = CGRect(x: 20, y: 140, width: compassSize, height: compassSize)
            
            self.addSubview(compass)
        }
    }
    
    // 좌표를 통해 주소에 관한 JSON 정보를 받는 함수
    func getAddressByCoordinates(latitude: Double, longitude: Double) {
        let urlString = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=\(longitude),\(latitude)&orders=roadaddr&output=json"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("v7mnq95bi3", forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
            request.addValue("lk60WJAxZidNrOZNur1IaX9ORKpyTrlQken7fQRn", forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("장소 가져오기 에러 발생 : \(String(describing: error))")
                return
            }
            
            // json 데이터를 넘겨서 상세 정보를 받는 함수
            self.parseAddressFromJson(data: data)

        }
        task.resume()
    }

    // json 데이터로 상세 정보 찾기
    func parseAddressFromJson(data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let results = json["results"] as? [[String: Any]], let region = results.first?["region"] as? [String: Any], let land = results.first?["land"] as? [String: Any] {
            print(json)
            
            let area1 = (region["area1"] as? [String: Any])?["name"] as? String ?? ""
            let area2 = (region["area2"] as? [String: Any])?["name"] as? String ?? ""
            let area3 = (region["area3"] as? [String: Any])?["name"] as? String ?? ""
            let area4 = (region["area4"] as? [String: Any])?["name"] as? String ?? ""
            let addition0 = (land["addition0"] as? [String: Any])?["value"] as? String ?? ""
            let addition1 = (land["addition1"] as? [String: Any])?["value"] as? String ?? ""
            let addition2 = (land["addition2"] as? [String: Any])?["value"] as? String ?? ""
            let addition3 = (land["addition3"] as? [String: Any])?["value"] as? String ?? ""
            let addition4 = (land["addition4"] as? [String: Any])?["value"] as? String ?? ""
            
            print(area1, area2, area3, area4, addition0, addition1, addition2, addition3, addition4)
        }
    }
}
