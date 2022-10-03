//
//  Category.swift
//  Yummy Meals
//
//  Created by Richard Witherspoon on 10/1/22.
//

import Foundation

struct CategoryResponse: Decodable {
    let categories: [Category]
    
    //MARK: - Preview Data
    static let previewData = Bundle.main.decode(CategoryResponse.self,
                                                from: "categoriesResponse.json")
}

struct Category: Decodable, Equatable, Hashable {
    let id: String
    let title: String
    let thumbnail: String
    let desc: String
    
    enum CodingKeys: String, CodingKey {
        case id = "idCategory"
        case title = "strCategory"
        case thumbnail = "strCategoryThumb"
        case desc = "strCategoryDescription"
    }
    
    
    //MARK: - Preview Data
    static let beef = Category(id: "1",
                               title: "Beef",
                               thumbnail: "https://www.themealdb.com/images/category/beef.png",
                               desc: "Beef is the culinary name for meat from cattle, particularly skeletal muscle. Humans have been eating beef since prehistoric times.[1] Beef is a source of high-quality protein and essential nutrients.[2]")
    
    static let all = CategoryResponse.previewData.categories
}
