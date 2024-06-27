//
//  SidebarItem.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/1/22.
//

import Foundation

struct SidebarItem: Hashable, Identifiable {
    let id = UUID()
    let title: String
    let symbol: String?
    
    static let search = SidebarItem(title: "Search", symbol: "magnifyingglass")
    static let favorites = SidebarItem(title: "Favorites", symbol: "heart")
    static let categories = SidebarItem(title: "Categories", symbol: nil)
}
