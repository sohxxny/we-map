//
//  LocationDetailsViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/15/24.
//

import UIKit

class LocationDetailsViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationDetailsCollectionView: UICollectionView!
    
    let dataArray = ["서울과학기술대학교", "은광여고", "아주아주아주아주아주아주긴이름"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationDetailsCollectionView.delegate = self
        locationDetailsCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let albumCell = locationDetailsCollectionView.dequeueReusableCell(withReuseIdentifier: "LocationDetailsAlbumCell", for: indexPath) as! LocationDetailsAlbumCell
        
        albumCell.featuredImage.image = UIImage(named: "bookmark-icon")
        albumCell.albumName.text = dataArray[indexPath.row]
        
        return albumCell
    }
    
    
    func configure(with addressString: String) {
        addressLabel.text = addressString
    }
    
    @IBAction func tapCloseLocationDetails(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("tapCloseLocationDetails"), object: nil)
    }
    

}
