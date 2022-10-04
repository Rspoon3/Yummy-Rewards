//
//  SidebarVC.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/1/22.
//

import UIKit
import Networking

class SidebarVC: UIViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Section, SidebarItem>! = nil
    private var collectionView: UICollectionView! = nil
    private var categories: [Category]?
    private let spinner = YummySpinner()
    private var selectedCategory: Category?

    private enum Section: String {
        case main
        case categories
    }
    
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureCollectionView()
        configureDataSource()
        applyMainSnapshots()
        loadCategories()
    }
    
    private func configureNavBar() {
        navigationItem.title = Bundle.appTitle
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .sidebar)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dropDelegate = self
        view.addSubview(collectionView)
    }
        
    
    //MARK: - Networking
    private func loadCategories() {
        spinner.addTo(view)

        Task {
            do {
                let response: CategoryResponse = try await APIService.shared.fetch(endpoint: .categories)
                categories = response.categories.sorted(by: \.title)
                applyCategoriesSnapshots()
                
                if let first = categories?.first {
                    show(first)
                    fetchAllCategoriesInBackground()
                }
            } catch {
                presentGeneralAlert(for: error)
            }
            
            spinner.removeFromSuperview()
        }
    }
    

    //MARK: Data Source
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            
            if let symbol = item.symbol {
                content.image = .init(systemName: symbol)
                cell.accessories = []
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
    
    private func show(_ category: Category) {
        guard selectedCategory != category else { return }
        
        selectedCategory = category
        let nav = UINavigationController(rootViewController: MealsVC(viewType: .category(category: category)))
        navigationController?.showDetailViewController(nav, sender: nil)
    }
    
    
    //MARK: - Private Helpers
    private func fetchAllCategoriesInBackground() {
        Task(priority: .background) {
            try await withThrowingTaskGroup(of: MealResponse.self) { group in
                
                for category in categories?.dropFirst() ?? [] {
                    group.addTask {
                        return try await MealsCache.shared.fetchMeals(for: category)
                    }
                }
                
                for try await _ in group {
//                    print("Finished fetching all categories in the background")
                }
            }
        }
    }
}


//MARK: - UICollectionViewDelegate
extension SidebarVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let item = dataSource.itemIdentifier(for: indexPath),
            let section = dataSource.snapshot().sectionIdentifier(containingItem: item)
        else {
            return
        }
        
        switch section {
        case .main:
            if indexPath.item == 0 {
                let nav = UINavigationController(rootViewController: SearchVC())
                navigationController?.showDetailViewController(nav, sender: nil)
            } else {
                let nav = UINavigationController(rootViewController: MealsVC(viewType: .favorites))
                navigationController?.showDetailViewController(nav, sender: nil)
            }
        case .categories:
            if let category = categories?.first(where: {$0.title == item.title}) {
                show(category)
            }
        }
    }
}


//MARK: - UICollectionViewDropDelegate
extension SidebarVC: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        _ = coordinator.session.loadObjects(ofClass: String.self) { strings in
            guard
                let data = strings.first?.data(using: .utf8),
                let meal = try? JSONDecoder().decode(Meal.self, from: data)
            else {
                return
            }
            
            
            if !PersistenceManager.shared.favoriteMeals.contains(where: {$0.id == meal.id}) {
                PersistenceManager.shared.favoriteMeals.append(meal)
            }
        }
    }
}
