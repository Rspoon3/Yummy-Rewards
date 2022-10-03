//
//  Yummy_RewardsTests.swift
//  Yummy RewardsTests
//
//  Created by Richard Witherspoon on 10/3/22.
//

import XCTest
@testable import Yummy_Rewards

final class Yummy_RewardsTests: XCTestCase {
    
    func testCategoryResponse() {
        let categories = CategoryResponse.previewData.categories
        XCTAssertEqual(categories.count, 14)
        XCTAssertEqual(categories.first?.id, "1")
        XCTAssertEqual(categories.first?.title, "Beef")
    }
    
    func testMealResponse() {
        let beefMeals = MealResponse.beef.meals
        XCTAssertEqual(beefMeals.count, 42)
        XCTAssertEqual(beefMeals.first?.id, "52874")
        XCTAssertEqual(beefMeals.first?.title, "Beef and Mustard Pie")
        
        let dessertMeals = MealResponse.dessert.meals
        XCTAssertEqual(dessertMeals.count, 64)
        XCTAssertEqual(dessertMeals.first?.id, "53049")
        XCTAssertEqual(dessertMeals.first?.title, "Apam balik")
        
        let apamBalik = Meal.apamBalik
        XCTAssertEqual(apamBalik?.id, "53049")
        XCTAssertEqual(apamBalik?.title, "Apam balik")
        XCTAssertEqual(apamBalik?.category, "Dessert")
        XCTAssertEqual(apamBalik?.area, "Malaysian")
        XCTAssertEqual(apamBalik?.thumbnail, "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg")
        XCTAssertEqual(apamBalik?.youtube, "https://www.youtube.com/watch?v=6R8ffRRJcrg")
        XCTAssertEqual(apamBalik?.source, "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ")
        XCTAssertEqual(apamBalik?.ingredients?.count, 10)
        XCTAssertEqual(apamBalik?.ingredients?.last?.title, "Chocolate Powder")
        XCTAssertEqual(apamBalik?.ingredients?.last?.measurement, "4 pounds")
    }
    
    func testIngredient() {
        let milk = Ingredient.milk
        XCTAssertEqual(milk.title, "Milk")
        XCTAssertEqual(milk.measurement, "200ml")
    }
    
    func testSideBarItem() {
        let search = SidebarItem.search
        XCTAssertEqual(search.title, "Search")
        XCTAssertEqual(search.symbol, "magnifyingglass")
        
        let favorites = SidebarItem.favorites
        XCTAssertEqual(favorites.title, "Favorites")
        XCTAssertEqual(favorites.symbol, "star")
        
        let categories = SidebarItem.categories
        XCTAssertEqual(categories.title, "Categories")
        XCTAssertEqual(categories.symbol, nil)
    }
}
