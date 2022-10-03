//
//  Ingredient.swift
//  Yummy Meals
//
//  Created by Richard Witherspoon on 10/1/22.
//

import Foundation


struct Ingredient: Codable, Hashable {
    var id = UUID()
    let title: String
    var measurement: String?
    
    
    //MARK: - Preview Data
    static let milk = Ingredient(title: "Milk", measurement: "200ml")
}
