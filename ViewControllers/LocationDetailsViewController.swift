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
        
        setupCollectionViewLayout(for: locationDetailsCollectionView, itemsPerRow: 3, spacing: 5, sectionInset: 0, isSquare: false)
        
        locationDetailsCollectionView.delegate = self
        locationDetailsCollectionView.dataSource = self
        
        loadingIndicator = LoadingIndicator(in: self.view)
        loadingIndicator.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2 - 210)
        loadingIndicator.setupLoadingIndicator()
        
        noAlbumLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingIndicator.OnOffLoadingIndicator(isOn: true)
        Task {
            // 최근 추억 앨범 넣기
            if let userInfo = GlobalUserManager.shared.globalUser {
                albumPreviewList = await createAlbumPreviewModel(coordinate: locationInfo.coordinate, userInfo: userInfo)
            }
            reloadPreview()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumPreviewList.count > 3 ? 3 : albumPreviewList.count
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
    
    // 앨범 프리뷰 셀 터치시 해당 앨범 프리뷰로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NotificationCenter.default.post(name:NSNotification.Name("tapAlbumPreview"), object: albumPreviewList[indexPath.row].albumRef)
    }
    
    func configure(with location: LocationInfo) {
        self.locationInfo = location
        addressLabel.text = locationInfo.address
    }
    
    // 컬렉션 뷰 업데이트
    func reloadPreview() {
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
