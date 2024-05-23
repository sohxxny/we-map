//
//  PhotoGalleryViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/23/24.
//

import UIKit
import FirebaseFirestore

class PhotoGalleryViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var photoGalleryCollectionView: UICollectionView!
    
    var albumRef: DocumentReference? = nil
    let image = UIImage(named: "test.jpeg")
    var list : [UIImage?]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionViewLayout(for: photoGalleryCollectionView, itemsPerRow: 4, spacing: 5, sectionInset: 0)
        
        photoGalleryCollectionView.delegate = self
        photoGalleryCollectionView.dataSource = self
        
        list = [image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image, image]
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoGalleryCell = photoGalleryCollectionView.dequeueReusableCell(withReuseIdentifier: "PhotoGalleryCell", for: indexPath) as! PhotoGalleryCell
        
        photoGalleryCell.imageView.image = list[indexPath.row]
        
        return photoGalleryCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        list.count
    }
}
