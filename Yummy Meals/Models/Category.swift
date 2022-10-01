//
//  Category.swift
//  Yummy Meals
//
//  Created by Richard Witherspoon on 10/1/22.
//

import Foundation

struct CategoryResponse: Decodable {
    let categories: [Category]
}

struct Category: Decodable {
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
}
