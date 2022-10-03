//
//  MealResponse.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/3/22.
//

import Foundation

struct MealResponse: Decodable {
    let meals: [Meal]
    
    //MARK: - Preview Data
    static let dessert = Bundle.main.decode(MealResponse.self,
                                            from: "dessertResponse.json")
    
    static let beef = Bundle.main.decode(MealResponse.self,
                                         from: "beefResponse.json")
}
