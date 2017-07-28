//
//  ImageStore.swift
//  PhotoLibrary
//
//  Created by Derrick Park on 2017-07-18.
//  Copyright © 2017 Derrick Park. All rights reserved.
//

import UIKit

class ImageStore {
    // The cache works very much like a dictionary. You are able to add, remove, and update values associated with a given key. Unlike a dictionary, the cache will automatically remove objects if the system gets low on memory.
    
    let cache = NSCache<NSString, UIImage>()
    
    func setImage(_ image: UIImage, forkey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}
