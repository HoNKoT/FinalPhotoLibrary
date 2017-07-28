//
//  PhotoStore.swift
//  PhotoLibrary
//
//  Created by Derrick Park on 2017-07-04.
//  Copyright © 2017 Derrick Park. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

enum TagsResult {
    case success([Tag])
    case failure(Error)
}

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

class PhotoStore {
    
    let imageStore = ImageStore()
    
    let persistentContainer: NSPersistentContainer = {
        let containter = NSPersistentContainer(name: "PhotoLibrary")
        containter.loadPersistentStores { (
            description, error) in
            
            if let error = error {
                print("Error setting up CoreData(\(error)).")
            }
        }
        return containter
    }()
    
    var asyncronizedContext : NSManagedObjectContext

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    init() {
        asyncronizedContext = persistentContainer.newBackgroundContext()
    }
    
    func fetchAllPhotos(completion: @escaping (PhotosResult) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)

        fetchRequest.sortDescriptors = [sortByDateTaken]
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    
    func fetchAllTags(completion: @escaping (TagsResult)-> Void) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)
        
        fetchRequest.sortDescriptors = [sortByName]
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allTags = try fetchRequest.execute()
                completion(.success(allTags))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func processPhotosRequest(data: Data?, error: Error?, completionHandler: @escaping (NSManagedObjectContext) -> PhotosResult) -> PhotosResult? {
        var result: PhotosResult = PhotosResult.failure(nil)
        asyncronizedContext.performAndWait {
            result = completionHandler(self.asyncronizedContext)
        }
        return result
    }
    
    private func processImageRequest(data: Data?, error: Error?, completionHandler: @escaping (NSManagedObjectContext) -> ImageResult) -> ImageResult? {
        var result: ImageResult = ImageResult.failure(nil)
        asyncronizedContext.performAndWait {
            result = completionHandler(self.asyncronizedContext)
        }
        return result
    }
    
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) {
        self.persistentContainer.performBackgroundTask { context in
            guard let photoKey = photo.photoID else {
                preconditionFailure("Photo expected to have a photoID.")
            }
            if let image = self.imageStore.image(forKey: photoKey) {
                OperationQueue.main.addOperation {
                    completion(.success(image))
                }
                return
            }
            guard let photoURL = photo.remoteURL else {
                preconditionFailure("Photo expected to have a remote URL.")
            }
            let request = URLRequest(url: photoURL as URL)
            let task = self.session.dataTask(with: request) { (data, response, error) in
                // result is UIImage
                let result = self.processImageRequest(data: data, error: error) { context in
                    guard let imageData = data, let image = UIImage(data: imageData) else {
                        // can't create an image(UIImage)
                        if data == nil {
                            return .failure(error!)
                        } else {
                            return .failure(PhotoError.imageCreationError)
                        }
                    }
                    
                    print("processImageRequest \(Thread.current)")
                    return .success(image)
                }

                if case let .success(image) = result {
                    self.imageStore.setImage(image, forkey: photoKey)
                }
                OperationQueue.main.addOperation {
                    completion(result)
                }
            }
            task.resume()
        }
    }
    
    func fetchInterestingPhotos(completion: @escaping (PhotosResult) -> Void) {
        persistentContainer.performBackgroundTask { context in
            let url = FlickrAPI.interestingPhotosURL
            let request = URLRequest(url: url)
            let task = self.session.dataTask(with: request) {
                (data, response, error) in
                // result is [Photo]
                var result = self.processPhotosRequest(data: data, error: error) { context in
                    guard let jsonData = data else {
                        return .failure(error!)
                    }
                    
                    print("processPhotosRequest \(Thread.current)")
                    //
                    return FlickrAPI.photos(fromJSON: jsonData, into: context)
                }

                if case .success = result {
                    do {
                        try self.persistentContainer.viewContext.save()
                    } catch let error {
                        result = .failure(error)
                    }
                }
                
                OperationQueue.main.addOperation {
                    completion(result)
                }
                
            }
            task.resume()
        }
    }
    
    
}
