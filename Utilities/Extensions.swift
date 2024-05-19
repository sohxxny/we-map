//
//  Extensions.swift
//  WeMap
//
//  Created by Lee Soheun on 4/18/24.
//

import Foundation
import UIKit

struct LocationInfo {
    var coordinate: (Double, Double)
    var address: String
    
    init(coordinate: (Double, Double), address: String) {
        self.coordinate = coordinate
        self.address = address
    }
}
