//
//  MainMapView.swift
//  WeMap
//
//  Created by Lee Soheun on 3/15/24.
//

import UIKit
import NMapsMap
import CoreLocation

protocol MapViewDelegate: AnyObject {
    func mapViewDidTap(_ mapView: MainMapView, coordinate: (Double, Double), address: String)
}

class MainMapView: NMFNaverMapView, CLLocationManagerDelegate, NMFMapViewTouchDelegate {
    
    weak var locationDelegate: MapViewDelegate?
    
    var locationManager: CLLocationManager!
    var compassButton: NMFCompassView!
    var locationButton: NMFLocationButton!
    var locationOverlay: NMFLocationOverlay!
    var currentLocation: CLLocation?
    var selectedCoordinate: (Double, Double)?
    var selectedAddress: String?
    var selectLocationMarker = NMFMarker()
    var albumMarkers = [NMFMarker]()
    
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
        setLocationButton()
        setMarker()
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
        getLocationInfo(latitude: latlng.lat, longitude: latlng.lng)
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
        self.showLocationButton = false
        self.showCompass = false
        self.mapView.positionMode = .direction
    }
    
    // 나침반 버튼 설정
    func setCompassButton() {
        compassButton = NMFCompassView()
        let compassSize: CGFloat = 40
        compassButton.mapView = self.mapView
        compassButton.frame = CGRect(x: 20, y: 140, width: compassSize, height: compassSize)
        self.addSubview(compassButton)
    }
    
    // 위치 버튼 설정
    func setLocationButton() {
        locationButton = NMFLocationButton()
        let locationButtonSize: CGFloat = 45
        locationButton.mapView = self.mapView
        self.addSubview(locationButton)
        
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locationButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            locationButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 130),
            locationButton.widthAnchor.constraint(equalToConstant: locationButtonSize),
            locationButton.heightAnchor.constraint(equalToConstant: locationButtonSize)
        ])
    }
    
    // 마커 설정
    func setMarker() {
        self.selectLocationMarker.iconImage = NMFOverlayImage(name: "marker-red-icon")
        self.selectLocationMarker.width = 50
        self.selectLocationMarker.height = 50
    }
    
    // 앨범 마커 생성
    func createAlbumMarker(latitude: Double, longitude: Double) -> NMFMarker {
        let albumMarker = NMFMarker()
        albumMarker.iconImage = NMFOverlayImage(name: "marker-blue-icon")
        albumMarker.width = 40
        albumMarker.height = 40
        albumMarker.position = NMGLatLng(lat: latitude, lng: longitude)
        albumMarker.mapView = self.mapView
        return albumMarker
    }
    
    // 마커 띄우기
    func showMarkerAtLocation(latitude: Double, longitude: Double) {
        DispatchQueue.main.async {
            // 선택 마커 띄우기
            self.selectLocationMarker.position = NMGLatLng(lat: latitude, lng: longitude)
            self.selectLocationMarker.mapView = self.mapView
            self.moveCameraByCoordinate(latitude, longitude)
        }
    }
    
    // 지도에 앨범 (저장했던 장소) 마커 띄우기
    func showAlbumMarker(coordinateList: [(Double, Double)]) {
        // 기존 마커 제거
        albumMarkers.forEach { $0.mapView = nil }
        albumMarkers.removeAll()
        
        for coordinate in coordinateList {
            albumMarkers.append(createAlbumMarker(latitude: coordinate.0, longitude: coordinate.1))
        }
    }
    
    // 특정 좌표로 카메라 이동
    func moveCameraByCoordinate(_ latitude: Double, _ longitude: Double) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude))
        cameraUpdate.animation = .fly   // 애니메이션 타입 설정
        cameraUpdate.animationDuration = 1.0  // 애니메이션 지속 시간 설정
        self.mapView.moveCamera(cameraUpdate)
    }
    
    // 주소 상세 화면 띄우기
    func showLocationDetails() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailViewController = storyboard.instantiateViewController(withIdentifier: "LocationDetailsViewController") as? LocationDetailsViewController {
            detailViewController.modalPresentationStyle = .fullScreen
        }
    }
    
    // 좌표를 통해 주소에 관한 JSON 정보를 받는 함수
    func getLocationInfo(latitude: Double, longitude: Double) {
        let urlString = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=\(longitude),\(latitude)&orders=roadaddr&output=json"
        guard let url = URL(string: urlString) else { return }
        
        guard let clientId = ConfigManager.shared.getValue(forKey: "NAVER_MAP_CLIENT_ID"),
              let clientSecret = ConfigManager.shared.getValue(forKey: "NAVER_MAP_CLIENT_SECRET") else { return }
        
        var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(clientId, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
            request.addValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        
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
    
    // 주소로 좌표를 알아내는 함수
    func getCoordicateByAddress(address: String) {
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=\(encodedAddress)"
        guard let url = URL(string: urlString) else { return }
        
        guard let clientId = ConfigManager.shared.getValue(forKey: "NAVER_MAP_CLIENT_ID"),
              let clientSecret = ConfigManager.shared.getValue(forKey: "NAVER_MAP_CLIENT_SECRET") else { return }
        
        var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(clientId, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
            request.addValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("좌표 가져오기 에러 발생 : \(String(describing: error))")
                return
            }
            
            // Json 데이터의 좌표 추출
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let addresses = json["addresses"] as? [[String: Any]], let xString = addresses.first?["x"] as? String, let yString = addresses.first?["y"] as? String {
                if let x = Double(xString), let y = Double(yString) {
                    self.showMarkerAtLocation(latitude: y, longitude: x)
                    self.selectedCoordinate = (x, y)
                    
                    self.locationDelegate?.mapViewDidTap(self, coordinate: self.selectedCoordinate!, address: self.selectedAddress!)
                }
            }
        }
        task.resume()
    }
    
    // json 데이터로 상세 정보 찾기
    func parseAddressFromJson(data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let results = json["results"] as? [[String: Any]], let region = results.first?["region"] as? [String: Any], let land = results.first?["land"] as? [String: Any] {
            
            // let area1 = (region["area1"] as? [String: Any])?["name"] as? String ?? ""  // 시, 도
            let area1Abbr = (region["area1"] as? [String: Any])?["alias"] as? String ?? ""  // 시, 도 축약
            let area2 = (region["area2"] as? [String: Any])?["name"] as? String ?? ""  // 구
            // let area3 = (region["area3"] as? [String: Any])?["name"] as? String ?? ""  // 동
            let area4 = (region["area4"] as? [String: Any])?["name"] as? String ?? ""
            let roadAddr = (land["name"]) as? String ?? ""  // 도로명
            let roadAddrDetail1 = (land["number1"]) as? String ?? ""  // 도로명 상세주소 1
            let roadAddrDetail2 = (land["number2"]) as? String ?? ""  // 도로명 상세주소 2
            let buildingName = (land["addition0"] as? [String: Any])?["value"] as? String ?? ""  // 건물 이름
            
            let address = [area1Abbr, area2, area4, roadAddr, roadAddrDetail1, roadAddrDetail2, buildingName].filter{ !$0.isEmpty }.joined(separator: " ")
            let queryAddress = [area2, area4, roadAddr, roadAddrDetail1, roadAddrDetail2].filter{ !$0.isEmpty }.joined(separator: " ")
        
            self.selectedAddress = address
            self.getCoordicateByAddress(address: queryAddress)
        }
    }
    
    // 쿼리를 통해 장소 배열을 받는 함수
    /*
    func getPlaceNameByCoordinate(query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://openapi.naver.com/v1/search/local.json?query=\(encodedQuery)&display=1&start=1&"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("", forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue("", forHTTPHeaderField: "X-Naver-Client-Secret")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("장소 가져오기 에러 발생 : \(String(describing: error))")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
            } else {
                print("HTTP 에러 발생")
            }
        }
        task.resume()
    }
     */
}
