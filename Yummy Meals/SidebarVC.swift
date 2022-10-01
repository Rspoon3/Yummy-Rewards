//
//  SidebarVC.swift
//  Yummy Meals
//
//  Created by Richard Witherspoon on 10/1/22.
//

import UIKit
import Networking

struct SidebarItem: Hashable, Identifiable {
    let id = UUID()
    let title: String
    let symbol: String?
    
    static let search = SidebarItem(title: "Search", symbol: "magnifyingglass")
    static let favorites = SidebarItem(title: "Favorites", symbol: "star")
    static let categories = SidebarItem(title: "Categories", symbol: nil)
}

class SidebarVC: UIViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Section, SidebarItem>! = nil
    private var collectionView: UICollectionView! = nil
    private var categories: [Category]?
    private let spinner = YummySpinner()

    enum Section: String {
        case main
        case categories
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Yummy Meals"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        configureCollectionView()
        configureDataSource()
        applyMainSnapshots()
        
        loadCategories()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .sidebar)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            
            if let symbol = item.symbol {
                content.image = .init(systemName: symbol)
            } else {
                content.textProperties.font = .preferredFont(forTextStyle: .headline)
                cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
            }
            
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, SidebarItem>(collectionView: collectionView) {
            (collectionView, indexPath, identifier) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
    
    
    //MARK: - Networking
    private func loadCategories() {
        spinner.addTo(view)

        Task {
            do {
                let response: CategoryResponse = try await APIService.shared.fetch(endpoint: .categories)
                categories = response.categories
                applyCategoriesSnapshots()
            } catch {
                presentGeneralAlert(for: error)
            }
            
            spinner.removeFromSuperview()
        }
    }
    
    
    //MARK: Data Source
    private func applyMainSnapshots() {
        var mainSnapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        mainSnapshot.append([.search, .favorites])
        dataSource.apply(mainSnapshot, to: .main, animatingDifferences: false)
    }
    
    private func applyCategoriesSnapshots() {
        guard let categories else { return }
        var categoriesSnapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        let rootItem = SidebarItem.categories
        let sidebarItems = categories.map{ SidebarItem(title: $0.title, symbol: "fork.knife")}
        
        categoriesSnapshot.append([rootItem])
        categoriesSnapshot.expand([rootItem])
        categoriesSnapshot.append(sidebarItems, to: rootItem)
        
        dataSource.apply(categoriesSnapshot, to: .categories, animatingDifferences: false)
    }
}
