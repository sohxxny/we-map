//
//  MainViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 2/26/24.
//

import UIKit
import NMapsMap

class MainViewController: BaseViewController {
    
    var mainMapView: MainMapView?
    var searchButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // 뷰 컨트롤러가 보이기 전에 호출
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainMapView = GlobalMapsManager.shared.getOrCreateView()
        searchButton = GlobalSearchButtonManager.shared.getOrCreateButton(target: self, action: #selector(tapSearchButton))
        
    }
    
    // 뷰 컨트롤러가 보인 후에 호출
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setViews(mainMapView: mainMapView!, searchButton: searchButton!)
    }
    
    // 뷰 컨트롤러가 사라지기 전에 호출
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainMapView?.removeFromSuperview()
        searchButton?.removeFromSuperview()
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
    }
    
    // 검색창을 눌렀을 때의 로직
    @objc func tapSearchButton() {
        print("검색 버튼 터치")
    }
}
