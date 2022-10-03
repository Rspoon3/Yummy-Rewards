//
//  TabVC.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/2/22.
//

import UIKit


class TabVC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [createCategoriesNC(), createFavoritesNC(), createSearchNC()]
    }
    
    func createCategoriesNC() -> UINavigationController{
        let favoritesListVC = CategoriesVC()
        favoritesListVC.tabBarItem = UITabBarItem(title: "Categories",
                                                  image: UIImage(systemName: "square.grid.2x2.fill"),
                                                  tag: 0)
        
        return UINavigationController(rootViewController: favoritesListVC)
    }
    
    func createFavoritesNC() -> UINavigationController{
        let favoritesListVC = MealsVC(viewType: .favorites)
        favoritesListVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        
        return UINavigationController(rootViewController: favoritesListVC)
    }
    
    func createSearchNC() -> UINavigationController{
        let searchVC = SearchVC()
        searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)
        
        return UINavigationController(rootViewController: searchVC)
    }
}

