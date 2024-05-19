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
    var locationOverlay: NMFLocationOverlay!
    var currentLocation: CLLocation?
    var selectedCoordinate: (Double, Double)?
    var selectedAddress: String?
    var selectLocationMarker = NMFMarker()
    
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
    
    // 마커 설정
    func setMarker() {
        self.selectLocationMarker.iconImage = NMFOverlayImage(name: "marker-red-icon")
        self.selectLocationMarker.width = 50
        self.selectLocationMarker.height = 50
    }
    
    // 마커 띄우기
    func showMarkerAtLocation(latitude: Double, longitude: Double) {
        DispatchQueue.main.async {
            self.selectLocationMarker.position = NMGLatLng(lat: latitude, lng: longitude)
            self.selectLocationMarker.mapView = self.mapView
            self.moveCameraByCoordinate(latitude, longitude)
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
            // detailViewController.latlng = latlng
            // viewController?.present(detailViewController, animated: true, completion: nil)
        }
    }
    
    // 좌표를 통해 주소에 관한 JSON 정보를 받는 함수
    func getLocationInfo(latitude: Double, longitude: Double) {
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
