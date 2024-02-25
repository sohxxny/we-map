//
//  MainTabBarViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 2/21/24.
//

import UIKit
import NMapsMap

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)
        
    }

}
