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
    @IBOutlet weak var noAlbumLabel: UILabel!
    
    var albumPreviewList: [AlbumPreviewModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationDetailsCollectionView.delegate = self
        locationDetailsCollectionView.dataSource = self
        
        noAlbumLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        albumPreviewList = []
        
        if albumPreviewList.isEmpty {
            noAlbumLabel.isHidden = false
        } else {
            noAlbumLabel.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumPreviewList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let albumCell = locationDetailsCollectionView.dequeueReusableCell(withReuseIdentifier: "LocationDetailsAlbumCell", for: indexPath) as! LocationDetailsAlbumCell
        
        albumCell.albumName.text = albumPreviewList[indexPath.row].albumName
        albumCell.featuredImage.image = albumPreviewList[indexPath.row].featuredImage
        return albumCell
    }
    
    
    func configure(with addressString: String) {
        addressLabel.text = addressString
    }
    
    @IBAction func tapCloseLocationDetails(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("tapCloseLocationDetails"), object: nil)
    }
    
    @IBAction func tapGotoCreateAlbum(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("tapGotoCreateAlbum"), object: nil)
    }
    
    

}
