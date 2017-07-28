//
//  PhotosViewController.swift
//  PhotoLibrary
//
//  Created by Derrick Park on 2017-07-04.
//  Copyright © 2017 Derrick Park. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = photoDataSource
        self.collectionView.delegate = self
        
        updateDataSource()
        
        store.fetchInterestingPhotos { (photosResult) in
            // when the task is done we will get the photosResult as [Photo]
            // async task
            self.updateDataSource()
        }
        
        // Do any additional setup after loading the view.
    }
    
    private func updateDataSource() {
        store.fetchAllPhotos { (photoResult) in
            switch photoResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto"?:
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                let photo = photoDataSource.photos[selectedIndexPath.row]
                let destinationVC = segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
  
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
        // Download the image data, which could take some time.
        store.fetchImage(for: photo) { (result) in
            // The index path for the photo might have changed between the time
            // the request started and finished, so we have to find the most recent indexPath
            guard let photoIndex = self.photoDataSource.photos.index(of: photo),
                case let .success(image) = result else { return }
            
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        }
    }
    
    
}
