//
//  MainViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 2/26/24.
//

import UIKit
import NMapsMap
import FloatingPanel

class MainViewController: BaseViewController, MapViewDelegate, FloatingPanelControllerDelegate {
    
    var fpc: FloatingPanelController!
    var mainMapView: MainMapView?
    var searchButton: UIButton?
    var locationInfo: LocationInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainMapView = GlobalMapsManager.shared.getOrCreateView()
        searchButton = GlobalSearchButtonManager.shared.getOrCreateButton(target: self, action: #selector(tapSearchButton))
        setViews(mainMapView: mainMapView!, searchButton: searchButton!)
        mainMapView?.locationDelegate = self
        
        // 바텀 시트
        fpc = FloatingPanelController(delegate: self)
        setBottomSheet(fpc: fpc)
        initialSetting(fpc: fpc, in: self)
        
        // 닫기 버튼 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(didTapCloseLocationDetails(_:)), name: NSNotification.Name("tapCloseLocationDetails"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didTapGotoCreateAlbum(_:)), name: NSNotification.Name("tapGotoCreateAlbum"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didTapCloseCreateAlbum(_:)), name: NSNotification.Name("tapCloseCreateAlbum"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didCreateAlbum(_:)), name: NSNotification.Name("createAlbum"), object: nil)
        
    }

    // 뷰 컨트롤러가 보이기 전에 호출
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // 지도가 터치될 때마다 호출
    func mapViewDidTap(_ mapView: MainMapView, coordinate: (Double, Double), address: String) {
        locationInfo = LocationInfo(coordinate: coordinate, address: address)
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let contentVC = storyboard.instantiateViewController(withIdentifier: "LocationDetailsViewController") as! LocationDetailsViewController
            setContent(add: contentVC, from: self, by: self.fpc)
            contentVC.configure(with: address)
        }
    }
    
    // 장소 상세 정보 닫기 버튼 터치 (홈으로)
    @objc func didTapCloseLocationDetails(_ notification: Notification) {
        initialSetting(fpc: fpc, in: self)
        fpc.move(to: .tip, animated: true)
        mainMapView?.selectLocationMarker.mapView = nil
    }
    
    // 앨범 생성 버튼 터치
    @objc func didTapGotoCreateAlbum(_ notification: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contentVC = storyboard.instantiateViewController(withIdentifier: "CreateAlbumViewController") as! CreateAlbumViewController
        contentVC.locationInfo = self.locationInfo
        setContent(add: contentVC, from: self, by: self.fpc)
        fpc.move(to: .full, animated: true)
    }
    
    // 앨범 생성 화면에서 취소 버튼 터치
    @objc func didTapCloseCreateAlbum(_ notification: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contentVC = storyboard.instantiateViewController(withIdentifier: "LocationDetailsViewController") as! LocationDetailsViewController
        setContent(add: contentVC, from: self, by: self.fpc)
        contentVC.configure(with: locationInfo.address)
        fpc.move(to: .half, animated: true)
    }
    
    // 앨범 생성 완료 시 마커 생성
    @objc func didCreateAlbum(_ notification: Notification) {
        guard let map = mainMapView else { return }
        map.albumMarkers.append(map.createAlbumMarker(latitude: locationInfo.coordinate.1, longitude: locationInfo.coordinate.0))
    }
    
    // 뷰를 나타내기
    func setViews(mainMapView: MainMapView, searchButton: UIButton) {
        if mainMapView.superview == nil {
            view.addSubview(mainMapView)
            setLayoutForMainMapView(mainMapView)
        }
        if searchButton.superview == nil {
            view.addSubview(searchButton)
            setLayoutForSearchButton(searchButton)
        }
    }
    
    // 지도 레이아웃 설정
    func setLayoutForMainMapView(_ mapView: MainMapView) {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -49),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // 검색 버튼 레이아웃 설정
    func setLayoutForSearchButton(_ button: UIButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 45)
        ])
        button.contentHorizontalAlignment = .left
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.masksToBounds = false
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
    }
    
    override func updateUI() {
        super.updateUI()
        
        self.mainMapView!.showAlbumMarker(coordinateList: GlobalUserManager.shared.globalUser!.albumCoordinateList)
    }
    
    // 검색창을 눌렀을 때의 로직
    @objc func tapSearchButton() {
        print("검색 버튼 터치")
    }
}
