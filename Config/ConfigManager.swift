//
//  ConfigManager.swift
//  WeMap
//
//  Created by Lee Soheun on 5/20/24.
//

import Foundation

class ConfigManager {
    static let shared = ConfigManager()
    private var configData: [String: Any]?

    init() {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let data = NSDictionary(contentsOfFile: path) as? [String: Any] {
            configData = data
        }
    }

    func getValue(forKey key: String) -> String? {
        return configData?[key] as? String
    }
}
