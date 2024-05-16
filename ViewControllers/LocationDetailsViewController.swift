//
//  LocationDetailsViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/15/24.
//

import UIKit

class LocationDetailsViewController: BaseViewController {
    
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure(with addressString: String) {
        addressLabel.text = addressString
    }
    
    @IBAction func tapCloseLocationDetails(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("tapCloseLocationDetails"), object: nil)
    }
    

}
