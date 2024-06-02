//
//  MemoryAlbumViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/22/24.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase

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
    
    @IBOutlet weak var morePhotoButton: UIButton!
    @IBOutlet weak var moreVideoButton: UIButton!
    @IBOutlet weak var moreChatButton: UIButton!
    
    @IBOutlet weak var memberListCollectionView: UICollectionView!
    @IBOutlet weak var photoPreviewCollectionView: UICollectionView!
    
    @IBOutlet weak var memberLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var videoLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var chatLoadingIndicator: UIActivityIndicatorView!
    
    var albumRef: DocumentReference!
    var address: String!
    var albumName: String!
    var memberInfoList: [AlbumMemberModel] = []
    var imagePreviewList: [PhotoViewModel] = []
    var videoPreviewList: [UIImage] = []  // 비디오
    var lastChat: String?  // 채팅
    var albumSettingViewController: AlbumSettingViewController!
    
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
        
        hideAllMemberViews(true)
        hideAllPhotoViews(true)
        hideAllVideoViews(true)
        hideAllChatViews(true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        albumSettingViewController = storyboard.instantiateViewController(withIdentifier: "AlbumSettingViewController") as? AlbumSettingViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 처음에 모든 뷰 숨기기
        emptyVideoLabel.isHidden = true
        emptyPhotoLabel.isHidden = true
        
        Task {
            (albumName, address) = await getAlbumNameAndAddress(albumRef: albumRef)!
            albumNameLabel.text = albumName
            addressLabel.text = address
        }
        
        // 멤버 정보
        Task {
            if memberInfoList.isEmpty {
                OnOffLoadingIndicator(memberLoadingIndicator, isOn: true)
                if let userInfo = GlobalUserManager.shared.globalUser {
                    memberInfoList = await getMemberInfo(albumRef: albumRef, userInfo: userInfo)!
                }
                OnOffLoadingIndicator(memberLoadingIndicator, isOn: false)
                hideAllMemberViews(false)
            } else {
                // 목록 비어있지 않으면 데이터만 불러오기
                OnOffLoadingIndicator(memberLoadingIndicator, isOn: false)
                if let userInfo = GlobalUserManager.shared.globalUser {
                    memberInfoList = await getMemberInfo(albumRef: albumRef, userInfo: userInfo)!
                }
            }
            numberOfMember.text = "\(memberInfoList.count)"
            memberListCollectionView.reloadData()
        }
        
        // 사진 정보
        Task {
            if imagePreviewList.isEmpty {
                OnOffLoadingIndicator(photoLoadingIndicator, isOn: true)
                imagePreviewList = await getAlbumImageList(in: albumRef)
                OnOffLoadingIndicator(photoLoadingIndicator, isOn: false)
                hideAllPhotoViews(false)
            } else {
                OnOffLoadingIndicator(photoLoadingIndicator, isOn: false)
                imagePreviewList = await getAlbumImageList(in: albumRef)
            }
            numberOfPhoto.text = "\(imagePreviewList.count)"
            photoPreviewCollectionView.reloadData()
            emptyPhotoLabel.isHidden = imagePreviewList.isEmpty ? false : true
        }
        
        // 비디오 정보
        Task {
            // 비디오 불러오기
            if videoPreviewList.isEmpty {
                OnOffLoadingIndicator(videoLoadingIndicator, isOn: true)
                // 비디오 불러오기 코드
                OnOffLoadingIndicator(videoLoadingIndicator, isOn: false)
                hideAllVideoViews(false)
            } else {
                OnOffLoadingIndicator(videoLoadingIndicator, isOn: false)
                // 비디오 불러오기 코드
            }
            emptyVideoLabel.isHidden = videoPreviewList.isEmpty ? false : true
        }
        
        // 채팅 정보
        Task {
            if lastChat == nil {
                OnOffLoadingIndicator(chatLoadingIndicator, isOn: true)
                lastChat = await getLastChat(documentId: albumRef.documentID)
                OnOffLoadingIndicator(chatLoadingIndicator, isOn: false)
                hideAllChatViews(false)
            } else {
                OnOffLoadingIndicator(chatLoadingIndicator, isOn: false)
                lastChat = await getLastChat(documentId: albumRef.documentID)
            }
            lastChatLabel.text = lastChat == nil ? "아직 채팅이 없습니다. 채팅을 시작해보세요!" : lastChat
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case memberListCollectionView:
            let memberListCell = memberListCollectionView.dequeueReusableCell(withReuseIdentifier: "AlbumMemberCell", for: indexPath) as! AlbumMemberCell
            if let profilePhoto = memberInfoList[indexPath.row].user.profilePhoto {
                setCustomImage(imageView: memberListCell.profileImage, image: profilePhoto)
            } else {
                setIconImage(imageView: memberListCell.profileImage, color: .weMapSkyBlue, icon: "user-icon")
            }
            
            if !memberInfoList[indexPath.row].isJoined {
                memberListCell.profileImage.alpha = 0.2
                memberListCell.loadingIndicator.isHidden = false
            } else {
                memberListCell.profileImage.alpha = 1.0
                memberListCell.loadingIndicator.isHidden = true
            }
            
            
            memberListCell.profileName.text = memberInfoList[indexPath.row].user.userName
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
    func hideAllMemberViews(_ on: Bool) {
        numberOfMember.isHidden = on
        memberListCollectionView.isHidden = on
    }
    
    func hideAllPhotoViews(_ on: Bool) {
        numberOfPhoto.isHidden = on
        morePhotoButton.isHidden = on
        photoPreviewCollectionView.isHidden = on
    }
    
    func hideAllVideoViews(_ on: Bool) {
        numberOfVideo.isHidden = on
        moreVideoButton.isHidden = on
    }
    
    func hideAllChatViews(_ on: Bool) {
        moreChatButton.isHidden = on
        lastChatView.isHidden = on
        lastChatLabel.isHidden = on
    }
    
    // 사진 전체보기 버튼
    @IBAction func tapMorePhotoButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let photoGalleryViewController = storyboard.instantiateViewController(withIdentifier: "PhotoGalleryViewController") as? PhotoGalleryViewController {
            photoGalleryViewController.albumRef = self.albumRef
            photoGalleryViewController.photoList = self.imagePreviewList
            photoGalleryViewController.updatedData = { data in
                self.imagePreviewList = data
            }
            photoGalleryViewController.modalPresentationStyle = .fullScreen
            present(photoGalleryViewController, animated: true)
        }
    }
    
    // 채팅 전체보기 버튼
    @IBAction func tapMoreChatButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let chatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            chatViewController.modalPresentationStyle = .fullScreen
            chatViewController.albumRef = self.albumRef
            chatViewController.memberInfoList = self.memberInfoList
            present(chatViewController, animated: true)
        }
    }
    
    
    // 로딩 인디케이터 켜거나 끄기
    func OnOffLoadingIndicator(_ view: UIActivityIndicatorView, isOn: Bool) {
        if isOn {
            view.startAnimating()
            view.isHidden = false
        } else {
            view.stopAnimating()
            view.isHidden = true
        }
    }
    
    // 뒤로가기
    @IBAction func tapBackButton(_ sender: UIButton) {
        NotificationCenter.default.post(name:NSNotification.Name("tapCloseCreateAlbum"), object: albumRef)
    }
    
    @IBAction func tapSettingButton(_ sender: UIButton) {
        albumSettingViewController.albumRef = self.albumRef
        albumSettingViewController.modalPresentationStyle = .fullScreen
        present(albumSettingViewController, animated: true)
    }
}
