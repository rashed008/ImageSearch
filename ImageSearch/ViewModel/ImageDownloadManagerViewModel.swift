//
//  ImageSearch
//
//  Created by Rashedon 01/22/2022.
//  Copyright © 2022 rashed. All rights reserved.
//


import Foundation
import UIKit

typealias ImageDownloadHandler = (_ image: UIImage?, _ url: URL, _ indexPath: IndexPath?, _ error: Error?) -> Void

final class ImageDownloadManagerViewModel {
    private var completionHandler: ImageDownloadHandler?
    lazy var imageDownloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.flickrTest.imageDownloadqueue"
        queue.qualityOfService = .userInteractive
        return queue
    }()
    let imageCache = NSCache<NSString, UIImage>()
    static let shared = ImageDownloadManagerViewModel()
    private init () {}
    
    func downloadImage(_ FlickrPhotoModel: FlickrPhotoModel, indexPath: IndexPath?, size: String = "m", handler: @escaping ImageDownloadHandler) {
        self.completionHandler = handler
        guard let url = FlickrPhotoModel.flickrImageURL(size) else {
            return
        }
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            print("Return cached Image for \(url)")
            self.completionHandler?(cachedImage, url, indexPath, nil)
        } else {
            if let operations = (imageDownloadQueue.operations as? [PGOperation])?.filter({$0.imageUrl.absoluteString == url.absoluteString && $0.isFinished == false && $0.isExecuting == true }), let operation = operations.first {
                print("Increase the priority for \(url)")
                operation.queuePriority = .veryHigh
            }else {
                print("Create a new task for \(url)")
                let operation = PGOperation(url: url, indexPath: indexPath)
                if indexPath == nil {
                    operation.queuePriority = .high
                }
                operation.downloadHandler = { (image, url, indexPath, error) in
                    if let newImage = image {
                        self.imageCache.setObject(newImage, forKey: url.absoluteString as NSString)
                    }
                    self.completionHandler?(image, url, indexPath, error)
                }
                imageDownloadQueue.addOperation(operation)
            }
        }
    }
    func slowDownImageDownloadTaskfor (_ FlickrPhotoModel: FlickrPhotoModel) {
        guard let url = FlickrPhotoModel.flickrImageURL() else {
            return
        }
        if let operations = (imageDownloadQueue.operations as? [PGOperation])?.filter({$0.imageUrl.absoluteString == url.absoluteString && $0.isFinished == false && $0.isExecuting == true }), let operation = operations.first {
            print("Reduce the priority for \(url)")
            operation.queuePriority = .low
        }
    }
    
    func cancelAll() {
        imageDownloadQueue.cancelAllOperations()
    }
    
}




