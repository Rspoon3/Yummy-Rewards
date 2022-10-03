//
//  PersistenceManager.swift
//  Yummy Meals
//
//  Created by Richard Witherspoon on 10/2/22.
//

import Foundation

public class PersistenceManager: ObservableObject {
    public static let shared = PersistenceManager()
    
    private init() {}
    
    @UserDefaultCodable("favoriteMeals", defaultValue: [])
    var favoriteMeals: [Meal]{
        willSet {
            objectWillChange.send()
        }
    }
}
