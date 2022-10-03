//
//  MealsVC.swift
//  Yummy Meals
//
//  Created by Richard Witherspoon on 10/1/22.
//

import UIKit
import Networking


class MealsVC: UIViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Section, Meal>! = nil
    private var collectionView: UICollectionView! = nil
    private var meals = [Meal]()
    private var viewType: ViewType
    private let spinner = YummySpinner()
    private let placeholder = EmptyPlaceholderView(symbol: "fork.knife",
                                                   text: "No meals available")
    
    
    private enum Section: String {
        case main
    }
    
    enum ViewType {
        case favorites
        case category(category: Category)
    }
    
    
    //MARK: - Initializer
    init(viewType: ViewType) {
        self.viewType = viewType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureSearchController()
        configureCollectionView()
        configureDataSource()
        configureForViewType()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if case .favorites = viewType {
            meals = PersistenceManager.shared.favoriteMeals
            applySnapshot(meals: meals, animated: false)
        }
    }
    
    private func configureNavBar() {
        switch viewType {
        case .favorites:
            navigationItem.title = "Favorites"
        case .category(let category):
            navigationItem.title = category.title
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureForViewType() {
        switch viewType {
        case .favorites:
            configureForFavorites()
        case .category(let category):
            loadMealsFor(category)
        }
    }
    
    private func loadMealsFor(_ category: Category) {
        spinner.addTo(view)
        
        Task {
            do {
                let response = try await MealsCache.shared.fetchMeals(for: category)
                meals = response.meals
                applySnapshot(meals: response.meals, animated: false)
            } catch {
                placeholder.addTo(view)
                presentGeneralAlert(for: error)
            }
        }
        
        spinner.removeFromSuperview()
    }
    
    private func configureForFavorites() {
        let favorites = PersistenceManager.shared.favoriteMeals
        
        if favorites.isEmpty {
            placeholder.addTo(view)
        } else {
            meals = favorites
            applySnapshot(meals: favorites, animated: false)
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
        let cellRegistration = UICollectionView.CellRegistration<MealCell, Meal> { (cell, indexPath, meal) in
            cell.configure(meal: meal)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Meal>(collectionView: collectionView) {
            (collectionView, indexPath, identifier) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
    
    private func applySnapshot(meals: [Meal], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Meal>()
        snapshot.appendSections([.main])
        snapshot.appendItems(meals)
        
        dataSource.apply(snapshot, animatingDifferences: animated)
        
        collectionView.isUserInteractionEnabled = !meals.isEmpty
        
        if meals.isEmpty {
            placeholder.addTo(view)
        } else {
            placeholder.removeFromSuperview()
        }
    }
}


extension MealsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            applySnapshot(meals: meals.sorted(by: \.title), animated: true)
            return
        }

        let filteredMeals = meals.filter{$0.title.localizedCaseInsensitiveContains(searchText)}
        applySnapshot(meals: filteredMeals, animated: true)
    }
}

extension MealsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if let meal = dataSource.itemIdentifier(for: indexPath) {
            let details = MealDetailsVC(meal: meal)
            navigationController?.pushViewController(details, animated: true)
        }
    }
}
