//
//  ImageSearch
//
//  Created by Rashedon 01/22/2022.
//  Copyright © 2022 rashed. All rights reserved.
//


import Foundation

public class PagingModel {
    public var totalPages: Int?
    public var numberOfElements: Int32?
    public var currentSize: Int = 20
    public var currentPage: Int?
    
    init(totalPages: Int, elements: Int32, currentPage: Int) {
        self.totalPages = totalPages
        self.numberOfElements = elements
        self.currentPage = currentPage
    }
}
