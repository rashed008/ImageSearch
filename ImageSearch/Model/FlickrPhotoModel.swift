//
//  ImageSearch
//
//  Created by Rashedon 01/22/2022.
//  Copyright © 2022 rashed. All rights reserved.
//


import UIKit

class FlickrPhotoModel : Equatable {
    let photoID : String
    let farm : Int
    let server : String
    let secret : String
    
    init (photoID:String,farm:Int, server:String, secret:String) {
        self.photoID = photoID
        self.farm = farm
        self.server = server
        self.secret = secret
    }
    
    func flickrImageURL(_ size:String = "m") -> URL? {
        if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg") {
            return url
        }
        return nil
    }
    
}

func == (lhs: FlickrPhotoModel, rhs: FlickrPhotoModel) -> Bool {
    return lhs.photoID == rhs.photoID
}
