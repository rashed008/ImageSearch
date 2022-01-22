//
//  ImageSearch
//
//  Created by Rashedon 01/22/2022.
//  Copyright © 2022 rashed. All rights reserved.
//

import Foundation
import UIKit

extension SearchViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches.searchResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlickrPhotoModelCell.identifier, for: indexPath) as! FlickrPhotoModelCell
        cell.imageView.isUserInteractionEnabled = true
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension SearchViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        self.perform(#selector(postNotification), with: nil, afterDelay: 0.1)
    }
    
    @objc func postNotification () {
        let FlickrPhotoModel = photoForIndexPath(indexPath: selectedIndexPath!)
        NotificationCenter.default.post(name: NSNotification.Name("LoadImage"), object: FlickrPhotoModel)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastRowIndex = collectionView.numberOfItems(inSection: 0) - 1
        if indexPath.row == lastRowIndex && PagingModel.self != nil {
            loadMorePhotos()
        }
        let FlickrPhotoModel = photoForIndexPath(indexPath: indexPath)
        (cell as! FlickrPhotoModelCell).imageView.image = #imageLiteral(resourceName: "placeholder")
        ImageDownloadManagerViewModel.shared.downloadImage(FlickrPhotoModel, indexPath: indexPath) { (image, url, indexPathh, error) in
            if let indexPathNew = indexPathh {
                DispatchQueue.main.async {
                    if let getCell = collectionView.cellForItem(at: indexPathNew) {
                        (getCell as? FlickrPhotoModelCell)!.imageView.image = image
                    }
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.loadMore {return}
        let FlickrPhotoModel = photoForIndexPath(indexPath: indexPath)
        ImageDownloadManagerViewModel.shared.slowDownImageDownloadTaskfor(FlickrPhotoModel)
    }
    
    // MARK: - Helper Method
    private func loadMorePhotos() {
        guard let searchText = self.searchTextField.text, searchText.count > 0 else {
            return
        }
        if !loadMore && PagingModel!.currentPage! < PagingModel!.totalPages! {
            loadMore = true
            self.callSearchApi(searchText: searchText, pageNo: PagingModel!.currentPage! + 1)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 3)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.loadMore {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewReuseIdentifier, for: indexPath) as! CustomFooterView
            self.footerView = aFooterView
            self.footerView?.backgroundColor = UIColor.clear
            return aFooterView
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewReuseIdentifier, for: indexPath)
            return headerView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.footerView?.prepareInitialAnimation()
        }
    }
    override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.footerView?.stopAnimate()
        }
    }
    
    //compute the scroll value and play witht the threshold to get desired effect
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold   = 100.0 ;
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold);
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(fabs(triggerThreshold),1.0);
        self.footerView?.setTransform(inTransform: CGAffineTransform.identity, scaleFactor: CGFloat(pullRatio))
        if pullRatio >= 1 {
            self.footerView?.animateFinal()
        }
        print("pullRatio:\(pullRatio)")
    }
    
    //compute the offset and call the load method
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        let pullHeight  = fabs(diffHeight - frameHeight);
        print("pullHeight:\(pullHeight)");
        if pullHeight == 0.0
        {
            if (self.footerView?.isAnimatingFinal)! {
                print("load more trigger")
                self.footerView?.startAnimate()
            }
        }
    }
    
    
    
}
