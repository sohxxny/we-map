//
//  MemoryAlbumViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/22/24.
//

import UIKit
import FirebaseFirestore

class MemoryAlbumViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var albumSettingButton: UIButton!
    @IBOutlet weak var lastChatView: UIView!
    @IBOutlet weak var lastChatLabel: UILabel!
    
    @IBOutlet weak var numberOfMember: UILabel!
    @IBOutlet weak var numberOfPhoto: UILabel!
    @IBOutlet weak var numberOfVideo: UILabel!
    @IBOutlet weak var emptyPhotoLabel: UILabel!
    @IBOutlet weak var emptyVideoLabel: UILabel!
    
    @IBOutlet weak var firstLine: UIView!
    @IBOutlet weak var secondLine: UIView!
    @IBOutlet weak var thirdLine: UIView!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var VideoLabel: UILabel!
    @IBOutlet weak var chatLabel: UILabel!
    
    @IBOutlet weak var morePhotoButton: UIButton!
    @IBOutlet weak var moreVideoButton: UIButton!
    @IBOutlet weak var moreChatButton: UIButton!
    
    @IBOutlet weak var memberListCollectionView: UICollectionView!
    @IBOutlet weak var photoPreviewCollectionView: UICollectionView!
    
    var albumRef: DocumentReference!
    var address: String!
    var albumName: String!
    var memberInfoList: [UserViewModel] = []
    var imagePreviewList: [PhotoViewModel] = []  // 새로 모델 만들어야 함
    var videoPreviewList: [UIImage] = []  // 비디오
    var lastChat: String? = nil  // 채팅
    var loadingIndicator: LoadingIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lastChatView.layer.cornerRadius = 10
        
        emptyPhotoLabel.isHidden = true
        emptyVideoLabel.isHidden = true
        
        memberListCollectionView.delegate = self
        memberListCollectionView.dataSource = self
        photoPreviewCollectionView.delegate = self
        photoPreviewCollectionView.dataSource = self
        setupCollectionViewLayout(for: photoPreviewCollectionView, itemsPerRow: 4, spacing: 3, sectionInset: 0)
        
        loadingIndicator = LoadingIndicator(in: self.view)
        loadingIndicator.setupLoadingIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 처음에 모든 뷰 숨기기
        hideAllViews(true)
        emptyVideoLabel.isHidden = true
        emptyPhotoLabel.isHidden = true
        loadingIndicator.OnOffLoadingIndicator(isOn: true)
        
        Task {
            (albumName, address) = await getAlbumNameAndAddress(albumRef: albumRef)!
            albumNameLabel.text = albumName
            addressLabel.text = address
        }
        
        Task {
            // 멤버 정보 불러오기
            if let userInfo = GlobalUserManager.shared.globalUser {
                memberInfoList = await getMemberInfo(albumRef: albumRef, userInfo: userInfo)!
            }
            numberOfMember.text = "\(memberInfoList.count)"
            
            // 사진 불러오기
            imagePreviewList = await getAlbumImageList(in: albumRef)
            numberOfPhoto.text = "\(imagePreviewList.count)"
            emptyPhotoLabel.isHidden = imagePreviewList.isEmpty ? false : true
            
            // 비디오 불러오기
            emptyVideoLabel.isHidden = videoPreviewList.isEmpty ? false : true
            
            // 마지막 채팅 불러오기
            if lastChat == nil {
                lastChatLabel.text = "아직 채팅이 없습니다. 채팅을 시작해보세요!"
            }
            
            reloadAlbum()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case memberListCollectionView:
            let memberListCell = memberListCollectionView.dequeueReusableCell(withReuseIdentifier: "AlbumMemberCell", for: indexPath) as! AlbumMemberCell
            if let profilePhoto = memberInfoList[indexPath.row].profilePhoto {
                setCustomImage(imageView: memberListCell.profileImage, image: profilePhoto)
            } else {
                setIconImage(imageView: memberListCell.profileImage, color: .weMapSkyBlue, icon: "user-icon")
            }
            memberListCell.profileName.text = memberInfoList[indexPath.row].userName
            return memberListCell
            
        case photoPreviewCollectionView:
            let albumPhotoPreviewCell = photoPreviewCollectionView.dequeueReusableCell(withReuseIdentifier: "AlbumPhotoPreviewCell", for: indexPath) as! AlbumPhotoPreviewCell
            let previewPhoto = imagePreviewList[indexPath.row].image
            albumPhotoPreviewCell.previewImage.image = previewPhoto
            return albumPhotoPreviewCell
        default:
            let memberListCell = memberListCollectionView.dequeueReusableCell(withReuseIdentifier: "AlbumMemberCell", for: indexPath) as! AlbumMemberCell
            return memberListCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case memberListCollectionView:
            return memberInfoList.count
        case photoPreviewCollectionView:
            return imagePreviewList.count > 4 ? 4 : imagePreviewList.count
        default:
            return 0
        }
    }
    
    // 모든 뷰 숨기기
    func hideAllViews(_ on: Bool) {
        memberLabel.isHidden = on
        photoLabel.isHidden = on
        VideoLabel.isHidden = on
        chatLabel.isHidden = on
        numberOfMember.isHidden = on
        numberOfPhoto.isHidden = on
        numberOfVideo.isHidden = on
        firstLine.isHidden = on
        secondLine.isHidden = on
        thirdLine.isHidden = on
        morePhotoButton.isHidden = on
        moreVideoButton.isHidden = on
        moreChatButton.isHidden = on
        lastChatView.isHidden = on
        lastChatLabel.isHidden = on
        memberListCollectionView.isHidden = on
        photoPreviewCollectionView.isHidden = on
    }
    
    // 컬렉션 뷰 재로드
    func reloadAlbum() {
        loadingIndicator.OnOffLoadingIndicator(isOn: false)
        memberListCollectionView.reloadData()
        photoPreviewCollectionView.reloadData()
        hideAllViews(false)
    }
    
    // 사진 전체보기 버튼
    @IBAction func tapMorePhotoButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let photoGalleryViewController = storyboard.instantiateViewController(withIdentifier: "PhotoGalleryViewController") as? PhotoGalleryViewController {
            photoGalleryViewController.albumRef = self.albumRef
            photoGalleryViewController.modalPresentationStyle = .fullScreen
            present(photoGalleryViewController, animated: true)
        }
    }
    
    // 뒤로가기
    @IBAction func tapBackButton(_ sender: UIButton) {
        NotificationCenter.default.post(name:NSNotification.Name("tapCloseCreateAlbum"), object: albumRef)
    }
    
}
