//
//  PhotoCollectionViewCell.swift
//  PhotoLibrary
//
//  Created by Derrick Park on 2017-07-06.
//  Copyright © 2017 Derrick Park. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
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
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
    
}
