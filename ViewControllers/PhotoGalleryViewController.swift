//
//  PhotoGalleryViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/23/24.
//

import UIKit
import FirebaseFirestore
import PhotosUI

class PhotoGalleryViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPickerViewControllerDelegate {

    @IBOutlet weak var photoGalleryCollectionView: UICollectionView!
    @IBOutlet weak var emptyPhotosLabel: UILabel!
    
    var albumRef: DocumentReference!
    var photoList: [PhotoViewModel]!
    var loadingIndicator: LoadingIndicator!
    var updatedData: (([PhotoViewModel]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionViewLayout(for: photoGalleryCollectionView, itemsPerRow: 4, spacing: 5, sectionInset: 0)
        
        photoGalleryCollectionView.delegate = self
        photoGalleryCollectionView.dataSource = self
        
        loadingIndicator = LoadingIndicator(in: self.view)
        loadingIndicator.setupLoadingIndicator()
        
        emptyPhotosLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingIndicator.OnOffLoadingIndicator(isOn: false)
        emptyPhotosLabel.isHidden = photoList.isEmpty ? false : true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoGalleryCell = photoGalleryCollectionView.dequeueReusableCell(withReuseIdentifier: "PhotoGalleryCell", for: indexPath) as! PhotoGalleryCell
        photoGalleryCell.imageView.image = photoList[indexPath.row].image
        
        return photoGalleryCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photoList.count
    }
    
    // 컬렉션 뷰 재로드
    func reloadPhotos() {
        loadingIndicator.OnOffLoadingIndicator(isOn: false)
        photoGalleryCollectionView.reloadData()
        photoGalleryCollectionView.isHidden = false
        
        emptyPhotosLabel.isHidden = photoList.isEmpty ? false : true
    }
    
    @IBAction func tapAddPhotoButton(_ sender: UIButton) {
        showImagePicker()
    }

    // 이미지 피커 세팅
    func showImagePicker() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.selectionLimit = 30
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    // 이미지 선택
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if !results.isEmpty {
            loadingIndicator.OnOffLoadingIndicator(isOn: true)
            emptyPhotosLabel.isHidden = true
        }
        let dispatchGroup = DispatchGroup()
        for result in results {
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    saveImage(image, in: self.albumRef) {
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
        }
        // 이미지 업로드 완료 후 실행
        dispatchGroup.notify(queue: .main) { [self] in
            Task {
                photoList = await getAlbumImageList(in: self.albumRef)
                reloadPhotos()
                if !results.isEmpty {
                    AlertHelper.showAlertWithNoButton(on: self, with: nil, message: "사진 추가가 완료되었습니다.")
                    updatedData?(photoList)
                }
            }
        }
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
