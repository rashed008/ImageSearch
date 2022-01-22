//
//  ImageSearch
//
//  Created by Rashedon 01/22/2022.
//  Copyright © 2022 rashed. All rights reserved.
//


import Foundation

extension SearchViewController {
    
    func callSearchApi (searchText: String, pageNo: Int) {
        flickr.searchFlickrForTerm(searchText, page: pageNo) { results, PagingModel, error in
            self.searchTextField.stopAnimating()
            if let PagingModel = PagingModel, PagingModel.currentPage == 1 {
                ImageDownloadManagerViewModel.shared.cancelAll()
                self.searches.searchResults.removeAll()
                self.collectionView?.reloadData()
            }
            
            if let error = error {
                print("Error searching: \(error)")
                return
            }
            
            if let results = results {
                print("Found \(results.searchResults.count) matching \(results.searchTerm)")
                self.searches.searchResults.append(contentsOf: results.searchResults)
                for photo in self.searches.searchResults {
                    print("URL:  \(photo.flickrImageURL()?.absoluteString ?? "")")
                }
                self.PagingModel = PagingModel
                self.collectionView?.reloadData()
            }
            self.loadMore = false
        }
    }
    
}
