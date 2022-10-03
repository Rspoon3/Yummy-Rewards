//
//  CategoriesVC.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/2/22.
//

import UIKit
import Networking


class CategoriesVC: UIViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Section, Category>! = nil
    private var collectionView: UICollectionView! = nil
    private var categories = [Category]()
    private let spinner = YummySpinner()
    private let placeholder = EmptyPlaceholderView(symbol: "square.grid.2x2",
                                                   text: "No meals available")
    
    
    private enum Section: String {
        case main
    }
    
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureSearchController()
        configureCollectionView()
        configureDataSource()
        loadCategories()
    }
        
    private func configureNavBar() {
        navigationItem.title = "Categories"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func loadCategories() {
        spinner.addTo(view)

        Task {
            do {
                let response: CategoryResponse = try await APIService.shared.fetch(endpoint: .categories)
                categories = response.categories.sorted(by: \.title)
                applySnapshot(categories: categories, animated: true)
                fetchAllCategoriesInBackground()
            } catch {
                presentGeneralAlert(for: error)
            }
            
            spinner.removeFromSuperview()
        }
    }
    
    private func configureSearchController(){
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
                                                            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let columns = CGFloat(Int(contentSize.width / 250))
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / max(2, columns)),
                                                  heightDimension: .estimated(100))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
            return section
        }
        return layout
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.isUserInteractionEnabled = false
        view.addSubview(collectionView)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<CategoryCell, Category> { (cell, indexPath, category) in
            cell.configure(category: category)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Category>(collectionView: collectionView) {
            (collectionView, indexPath, identifier) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
    
    private func applySnapshot(categories: [Category], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Category>()
        snapshot.appendSections([.main])
        snapshot.appendItems(categories)
        
        dataSource.apply(snapshot, animatingDifferences: animated)
        
        collectionView.isUserInteractionEnabled = !categories.isEmpty
        
        if categories.isEmpty {
            placeholder.addTo(view)
        } else {
            placeholder.removeFromSuperview()
        }
    }
    
    
    //MARK: - Private Helpers
    private func fetchAllCategoriesInBackground() {
        Task(priority: .background) {
            try await withThrowingTaskGroup(of: MealResponse.self) { group in
                
                for category in categories {
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


extension CategoriesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            applySnapshot(categories: categories.sorted(by: \.title), animated: true)
            return
        }

        let filteredCategories = categories.filter{$0.title.localizedCaseInsensitiveContains(searchText)}
        applySnapshot(categories: filteredCategories, animated: true)
    }
}

extension CategoriesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        guard let category = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        let details = MealsVC(viewType: .category(category: category))
        navigationController?.pushViewController(details, animated: true)
    }
}

