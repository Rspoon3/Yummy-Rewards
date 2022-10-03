//
//  SearchVC.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/1/22.
//

import UIKit
import Networking
import Combine


class SearchVC: UIViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Section, Meal>! = nil
    private var collectionView: UICollectionView! = nil
    private var meals = [Meal]()
    private var cancellables = Set<AnyCancellable>()
    @Published private var searchText: String?
    private let placeholder = EmptyPlaceholderView(symbol: "magnifyingglass",
                                                   text: "No search results")
    
    
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
        configureCancellables()
    }
    
    private func configureNavBar() {
        navigationItem.title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
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
    
    private func configureCancellables() {
        $searchText
            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .flatMap { searchText -> AnyPublisher<[Meal], Never> in
                guard let searchText, !searchText.isEmpty else {
                    return Just([]).eraseToAnyPublisher()
                }
                return APIService.shared.publisher(endpoint: .searchName(mealName: searchText), type: MealResponse.self)
                    .map(\.meals)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .map { $0.sorted(by: \.title) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { [weak self] in
                if case .failure(let error) = $0 {
                    self?.presentGeneralAlert(for: error)
                }
            }, receiveValue: { [weak self] meals in
                self?.applySnapshot(meals: meals, animated: true)
            }).store(in: &cancellables)
        
    }
}


extension SearchVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text
    }
}

extension SearchVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if let meal = dataSource.itemIdentifier(for: indexPath) {
            let details = MealDetailsVC(meal: meal)
            navigationController?.pushViewController(details, animated: true)
        }
    }
}
