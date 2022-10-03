//
//  MealResponse.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/1/22.
//

import Foundation

struct Meal: Codable, Hashable {
    let id: String
    let title: String
    let thumbnail: String
    
    //Details
    let area: String?
    let instructions: String?
    let youtube: String?
    let ingredients: [Ingredient]?
    let source: String?
    let category: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case title = "strMeal"
        case thumbnail = "strMealThumb"
        case area = "strArea"
        case instructions = "strInstructions"
        case youtube = "strYoutube"
        case source = "strSource"
        case category = "strCategory"
    }
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) {
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: CodingKeys.id)
        title = try container.decode(String.self, forKey: CodingKeys.title)
        thumbnail = try container.decode(String.self, forKey: CodingKeys.thumbnail)
        area = try container.decodeIfPresent(String.self, forKey: .area)
        instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
        youtube = try container.decodeIfPresent(String.self, forKey: .youtube)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        category = try container.decodeIfPresent(String.self, forKey: .category)

        
        //Dynamic coding keys
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var ingredientsDict = [Int: String]()
        var measurementsDict = [Int: String]()
        
        for key in dynamicContainer.allKeys.sorted(by: \.stringValue) {
            guard let dynamicKey = DynamicCodingKeys(stringValue: key.stringValue) else {
                continue
            }
            
            let string = try dynamicContainer.decodeIfPresent(String.self, forKey: dynamicKey)
            
            if let string {
                if key.stringValue.contains("strIngredient"),
                   let component = key.stringValue.components(separatedBy: "strIngredient").last,
                   let value = Int(component) {
                    ingredientsDict[value] = string
                } else if key.stringValue.contains("strMeasure"),
                          let component = key.stringValue.components(separatedBy: "strMeasure").last,
                          let value = Int(component){
                    measurementsDict[value] = string
                }
            }
        }
        
        var tempIngredients = [Ingredient]()
        for i in 0..<ingredientsDict.count + 1 {
            if let title = ingredientsDict[i], !title.isEmpty {
                let ingredient = Ingredient(title: title,
                                            measurement: measurementsDict[i])
                tempIngredients.append(ingredient)
            }
        }
        
        ingredients = tempIngredients
    }
    
    
    //MARK: - Preview Data
    static let dessert = MealResponse.dessert.meals
    
    static let apamBalik = Bundle.main.decode(MealResponse.self,
                                              from: "apamBalik.json").meals.first
}
