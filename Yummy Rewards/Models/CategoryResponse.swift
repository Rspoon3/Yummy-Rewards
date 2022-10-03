//
//  CategoryResponse.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/3/22.
//

import Foundation

struct CategoryResponse: Decodable {
    let categories: [Category]
    
    //MARK: - Preview Data
    static let previewData = Bundle.main.decode(CategoryResponse.self,
                                                from: "categoriesResponse.json")
}
