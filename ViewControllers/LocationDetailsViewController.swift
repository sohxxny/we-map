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
    
    var albumPreviewList: [AlbumPreviewModel] = []
    var locationInfo: LocationInfo!
    var loadingIndicator: LoadingIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationDetailsCollectionView.delegate = self
        locationDetailsCollectionView.dataSource = self
        
        loadingIndicator = LoadingIndicator(in: self.view)
        loadingIndicator.setupLoadingIndicator()
        
        noAlbumLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingIndicator.OnOffLoadingIndicator(isOn: true) // 되는지 모르겠음
        Task {
            // 최근 추억 앨범 넣기
            if let userInfo = GlobalUserManager.shared.globalUser {
                albumPreviewList = await createAlbumPreviewModel(coordinate: locationInfo.coordinate, userInfo: userInfo)
            }
            albumPreviewList.sort { $0.timeStamp.seconds > $1.timeStamp.seconds }
            updatePreview()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumPreviewList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let albumCell = locationDetailsCollectionView.dequeueReusableCell(withReuseIdentifier: "LocationDetailsAlbumCell", for: indexPath) as! LocationDetailsAlbumCell
        
        albumCell.albumName.text = albumPreviewList[indexPath.row].albumName
        if let featuredImage = albumPreviewList[indexPath.row].featuredImage {
            albumCell.featuredImage.image = featuredImage
            albumCell.noImageLabel.isHidden = true
        } else {
            albumCell.noImageLabel.isHidden = false
        }
        
        return albumCell
    }
    
    func configure(with location: LocationInfo) {
        self.locationInfo = location
        addressLabel.text = locationInfo.address
    }
    
    func updatePreview() {
        loadingIndicator.OnOffLoadingIndicator(isOn: false)
        locationDetailsCollectionView.reloadData()
        locationDetailsCollectionView.isHidden = false
        
        if albumPreviewList.isEmpty {
            noAlbumLabel.isHidden = false
        } else {
            noAlbumLabel.isHidden = true
        }
    }
    
    @IBAction func tapCloseLocationDetails(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("tapCloseLocationDetails"), object: nil)
    }
    
    @IBAction func tapGotoCreateAlbum(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("tapGotoCreateAlbum"), object: nil)
    }

}
