//
//  Endpoint.swift
//  
//
//  Created by Richard Witherspoon on 10/1/22.
//

import Foundation


public enum Endpoint {
    case searchName(mealName: String)
    case searchIngredient(mainIngredient: String)
    case details(mealID: String)
    case meals(category: String)
    case randomMeal
    case categories
    case areas
    
    var info: EndpointInfo {
        switch self {
        case .searchName(let mealName):
            return .init("search", queryItem: .init(name: "s", value: mealName))
        case .searchIngredient(let mainIngredient):
            return .init("search", queryItem: .init(name: "f", value: mainIngredient))
        case .meals(let category):
            return .init("filter", queryItem: .init(name: "c", value: category))
        case .details(let mealID):
            return .init("lookup", queryItem: .init(name: "i", value: mealID))
        case .randomMeal:
            return .init("random")
        case .categories:
            return .init("categories")
        case .areas:
            return .init("list", queryItem: .init(name: "a", value: "list"))
        }
    }
}
