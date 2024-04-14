//
//  MainViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 2/26/24.
//

import UIKit

class MainViewController: UIViewController {
    var mainMapView: MainMapView?
    var searchButton: UIButton?
    
    override func viewDidLoad() {
        mainMapView = GlobalMapsManager.shared.getOrCreateView()
        searchButton = GlobalSearchButtonManager.shared.getOrCreateButton(target: self, action: #selector(tapSearchButton))
        setupInitialViews(mainMapView: mainMapView!, searchButton: searchButton!)
        
        // 지도 화면 터치 시 키보드 내리는 클로저
        mainMapView?.onMapsTap = { [weak self] in
            self?.view.endEditing(true)
        }
    }

    // 뷰 컨트롤러가 보이기 전에 호출
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let mapView = mainMapView, mapView.superview == nil {
            view.addSubview(mapView)
            setLayoutForMainMapView(mapView)
        }
        if let button = searchButton, button.superview == nil {
            view.addSubview(button)
            setLayoutForSearchButton(button)
        }
        updateViewLayouts()
    }
    
    // 뷰 컨트롤러가 사라지기 전에 호출
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainMapView?.removeFromSuperview()
        searchButton?.removeFromSuperview()
    }
    
    // 뷰를 처음 설정하고 추가
    func setupInitialViews(mainMapView: MainMapView, searchButton: UIButton) {
        if mainMapView.superview == nil {
            view.addSubview(mainMapView)
            setLayoutForMainMapView(mainMapView)
        }
        if searchButton.superview == nil {
            view.addSubview(searchButton)
            setLayoutForSearchButton(searchButton)
        }
    }
    
    // 뷰 레이아웃 업데이트
    func updateViewLayouts() {
        view.layoutIfNeeded()
    }
    
    // 지도 레이아웃 설정
    func setLayoutForMainMapView(_ mapView: MainMapView) {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
        button.clipsToBounds = true
    }
    
    // 검색창을 눌렀을 때의 로직
    @objc func tapSearchButton() {
        print("검색 버튼 터치")
    }
    
    // 화면 터치 이벤트 함수
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        // 화면 터치 시 키보드 내리기
        self.view.endEditing(true)
    }
}