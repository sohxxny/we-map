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
    @IBOutlet weak var noAlbumLabel: UILabel!
    
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
            numberOfAlbum.text = "\(albumPreviewList.count)"
            noAlbumLabel.isHidden = albumPreviewList.isEmpty ? false : true
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
        return albumPreviewList.count > 3 ? 3 : albumPreviewList.count
    }
    
    // 앨범 프리뷰 셀 터치시 해당 앨범 프리뷰로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let memoryAlbumViewController = storyboard.instantiateViewController(withIdentifier: "MemoryAlbumViewController") as! MemoryAlbumViewController
        memoryAlbumViewController.albumRef = albumPreviewList[indexPath.row].albumRef
        _ = memoryAlbumViewController.view
        memoryAlbumViewController.topConstraint.constant = 15
        memoryAlbumViewController.modalPresentationStyle = .fullScreen
        present(memoryAlbumViewController, animated: true)
    }
    
    func reloadPreview() {
        loadingIndicator.OnOffLoadingIndicator(isOn: false)
        albumPreviewCollectionView.reloadData()
        albumPreviewCollectionView.isHidden = false
    }
    
}
