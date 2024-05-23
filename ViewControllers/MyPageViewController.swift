//
//  MyPageViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 4/28/24.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class MyPageViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var numberOfAlbum: UILabel!
    @IBOutlet weak var albumPreviewCollectionView: UICollectionView!
    
    var albumPreviewList: [AlbumPreviewModel] = []
    var loadingIndicator: LoadingIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionViewLayout(for: albumPreviewCollectionView, itemsPerRow: 3, spacing: 5, sectionInset: 0, isSquare: false)
        
        // 이미지 둥글게
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        
        // 백 버튼 설정 함수
        setBackButton(vc: self)
        
        albumPreviewCollectionView.delegate = self
        albumPreviewCollectionView.dataSource = self
        
        loadingIndicator = LoadingIndicator(in: self.view)
        loadingIndicator.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2 - 210)
        loadingIndicator.setupLoadingIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingIndicator.OnOffLoadingIndicator(isOn: true)
        
        if let myViewModel = GlobalFriendsManager.shared.globalMyViewModel {
            
            // 프로필 이미지 불러오기
            if let profilePhoto = myViewModel.profilePhoto {
                setCustomImage(imageView: profileImage, image: profilePhoto)
            } else {
                setIconImage(imageView: profileImage, color: .weMapSkyBlue, icon: "user-icon")
            }
            
            // 프로필 이름 불러오기
            profileName.text = myViewModel.userName
        }
        
        Task {
            // 최근 추억 앨범 넣기
            if let userInfo = GlobalUserManager.shared.globalUser {
                albumPreviewList = await createAllAlbumPreviewModel(userInfo: userInfo)
            }
            albumPreviewList.sort { $0.timeStamp.nanoseconds > $1.timeStamp.nanoseconds }
            numberOfAlbum.text = "\(albumPreviewList.count)"
            print(albumPreviewList)
            reloadPreview()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myPageAlbumPreviewCell = albumPreviewCollectionView.dequeueReusableCell(withReuseIdentifier: "MyPageAlbumPreviewCell", for: indexPath) as! MyPageAlbumPreviewCell
        myPageAlbumPreviewCell.albumName.text = albumPreviewList[indexPath.row].albumName
        if let featuredImage = albumPreviewList[indexPath.row].featuredImage {
            myPageAlbumPreviewCell.featuredImage.image = featuredImage
            myPageAlbumPreviewCell.noImageLabel.isHidden = true
        } else {
            myPageAlbumPreviewCell.noImageLabel.isHidden = false
        }
        
        return myPageAlbumPreviewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumPreviewList.count > 4 ? 4 : albumPreviewList.count
    }
    
    func reloadPreview() {
        loadingIndicator.OnOffLoadingIndicator(isOn: false)
        albumPreviewCollectionView.reloadData()
        albumPreviewCollectionView.isHidden = false
        
//        if albumPreviewList.isEmpty {
//            noAlbumLabel.isHidden = false
//        } else {
//            noAlbumLabel.isHidden = true
//        }
    }
    
}
