//
//  ImageSearch
//
//  Created by Rashedon 01/22/2022.
//  Copyright © 2022 rashed. All rights reserved.
//


import UIKit

class SearchTextField: UITextField {
    var activityIndicator : UIActivityIndicatorView!
    override func awakeFromNib() {
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        activityIndicator.frame = self.bounds
    }
    
    func startAnimating () {
        activityIndicator.startAnimating()
    }
    func stopAnimating () {
        activityIndicator.stopAnimating()
    }
    
}
