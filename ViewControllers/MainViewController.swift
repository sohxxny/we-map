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
    }

    // 뷰 컨트롤러가 보이기 전에 호출
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // 지도가 터치될 때마다 호출
    func mapViewDidTap(_ mapView: MainMapView, coordinate: (Double, Double), address: String) {
        print("coordinate: \(coordinate), Address: \(address)")
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let contentVC = storyboard.instantiateViewController(withIdentifier: "LocationDetailsViewController") as! LocationDetailsViewController
            setContent(add: contentVC, from: self, by: self.fpc)
            contentVC.configure(with: address)
        }
    }
    
    @objc func didTapCloseLocationDetails(_ notification: Notification) {
        initialSetting(fpc: fpc, in: self)
        fpc.move(to: .tip, animated: true)
        mainMapView?.selectLocationMarker.mapView = nil
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
    
    // 검색창을 눌렀을 때의 로직
    @objc func tapSearchButton() {
        print("검색 버튼 터치")
    }
}
