//
//  Flickr.swift
//  FlickrTest
//
//  Created by Rashedon 07/06/18.
//  Copyright © 2018 gautam1001. All rights reserved.
//

import Foundation

import UIKit

let apiKey = "de24642a8668fb0318ec5b9cecfda18c"

class Flickr {
    func searchFlickrForTerm(_ searchTerm: String, page: Int = 1,completion : @escaping (_ results: FlickrSearchResultsModelModel?, _ PagingModel: PagingModel?,_ error : NSError?) -> Void){
        
        guard let searchURL = flickrSearchURLForSearchTerm(searchTerm,page: page) else {
            let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
            completion(nil, nil,APIError)
            return
        }
        
        let searchRequest = URLRequest(url: searchURL)
        
        URLSession.shared.dataTask(with: searchRequest, completionHandler: { (data, response, error) in
            
            if let _ = error {
                let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                OperationQueue.main.addOperation({
                    completion(nil, nil,APIError)
                })
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                  let data = data else {
                      let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                      OperationQueue.main.addOperation({
                          completion(nil, nil,APIError)
                      })
                      return
                  }
            
            do {
                
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],
                      let stat = resultsDictionary["stat"] as? String else {
                          
                          let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                          OperationQueue.main.addOperation({
                              completion(nil, nil,APIError)
                          })
                          return
                      }
                
                switch (stat) {
                case "ok":
                    print("Results processed OK")
                case "fail":
                    if let message = resultsDictionary["message"] {
                        
                        let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:message])
                        
                        OperationQueue.main.addOperation({
                            completion(nil, nil,APIError)
                        })
                    }
                    
                    let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: nil)
                    
                    OperationQueue.main.addOperation({
                        completion(nil, nil,APIError)
                    })
                    
                    return
                default:
                    let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, nil,APIError)
                    })
                    return
                }
                print(resultsDictionary)
                guard let photosContainer = resultsDictionary["photos"] as? [String: AnyObject], let photosReceived = photosContainer["photo"] as? [[String: AnyObject]] else {
                    
                    let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, nil,APIError)
                    })
                    return
                }
                var pagingModel : PagingModel?
                var FlickrPhotoModels = [FlickrPhotoModel]()
                
                for photoObject in photosReceived {
                    guard let photoID = photoObject["id"] as? String,
                          let farm = photoObject["farm"] as? Int ,
                          let server = photoObject["server"] as? String ,
                          let secret = photoObject["secret"] as? String else {
                              break
                          }
                    let FlickrPhotoModel = FlickrPhotoModel(photoID: photoID, farm: farm, server: server, secret: secret)
                    FlickrPhotoModels.append(FlickrPhotoModel)
                }
                
                if let currentPage = photosContainer["page"] as? Int,
                   let totalPages = photosContainer["pages"] as? Int ,
                   let numberOfElements = photosContainer["total"] as? String {
                    pagingModel = PagingModel(totalPages: totalPages, elements: Int32(numberOfElements)!, currentPage: currentPage)
                }
                
                OperationQueue.main.addOperation({
                    completion(FlickrSearchResultsModelModel(searchResults: FlickrPhotoModels),pagingModel ,nil)
                })
                
            } catch _ {
                completion(nil, nil,nil)
                return
            }
            
            
        }) .resume()
    }
    
    fileprivate func flickrSearchURLForSearchTerm(_ searchTerm:String, page: Int = 1) -> URL? {
        
        guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedTerm)&per_page=20&format=json&nojsoncallback=1&page=\(page)"
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        
        return url
    }
}
