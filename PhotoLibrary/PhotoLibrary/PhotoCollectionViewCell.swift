//
//  PhotoCollectionViewCell.swift
//  PhotoLibrary
//
//  Created by Derrick Park on 2017-07-06.
//  Copyright © 2017 Derrick Park. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var favorite: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    public var photo: Photo? = nil
    
    override func awakeFromNib() {
        // when the cell is first created.
        super.awakeFromNib()
        update(with: nil)
    }
    
    override func prepareForReuse() {
        // when the cell is getting reused.
        super.prepareForReuse()
        update(with: nil)
    }
    
    func update(with image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
            
            if (photo?.favorite ?? false) {
                favorite.backgroundColor = UIColor.red
            } else {
                favorite.backgroundColor = nil
            }
            
            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
            lpgr.minimumPressDuration = 0.5
            lpgr.delaysTouchesBegan = true
            lpgr.delegate = self
            addGestureRecognizer(lpgr)
            
        } else {
            spinner.startAnimating()
            imageView.image = nil
            imageView.gestureRecognizers = nil
            favorite.backgroundColor = nil
        }
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizerState.began {
            
            if (photo == nil) {
                return
            }
            
            if (photo?.favorite ?? false) {
                photo?.favorite = true
                photo?.setValue(true, forKey: "favorite")
                favorite.backgroundColor = nil
                print("off")
            } else {
                photo?.favorite = false
                photo?.setValue(false, forKey: "favorite")
                favorite.backgroundColor = UIColor.red
                print("on")
            }
            
            do {
                // does not work.. why?
                try photo?.managedObjectContext?.save()
            } catch let error as NSError {
                print("Can not save. \(error)")
            }
            // have to save
            
        }
        
    }
    
}
