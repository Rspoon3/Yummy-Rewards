//
//  SidebarVCViewModel.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 4/18/24.
//

import UIKit
import Networking
import Combine

final class SidebarVCViewModel {
    private var subscriptions = Set<AnyCancellable>()
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, SidebarItem>! = nil
    private let repository = YummyRewardsRepository()
    private var categoriesStore = CategoriesStore.shared
    var selectedCategory: Category?
    public enum Section: String {
        case main
        case categories
    }
    
    // MARK: - Initializer
    
    init() {
        Task {
            await categoriesStore.$categories
                .dropFirst()
                .eraseToAnyPublisher()
//                .map { SidebarItem(title: $0.title, symbol: "fork.knife") }
                .sink { [weak self] categories in
                    print("RSW ", categories.count)
                    let sorted = categories.sorted(by: \.title)
                    let items = sorted.map { SidebarItem(title: $0.title, symbol: "fork.knife") }
                    self?.applyCategoriesSnapshots(items: items)
                }.store(in: &subscriptions)
        }
    }
    
    // MARK: - Data Source
    
    func configureDataSource(for collectionView: UICollectionView) {
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
    
    func applyMainSnapshots() {
        var mainSnapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        mainSnapshot.append([.search, .favorites])
        dataSource.apply(mainSnapshot, to: .main, animatingDifferences: false)
    }
    
    private func applyCategoriesSnapshots(items: [SidebarItem]) {
        var categoriesSnapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        let rootItem = SidebarItem.categories
        guard !items.isEmpty else { return }
        
        categoriesSnapshot.append([rootItem])
        categoriesSnapshot.expand([rootItem])
        categoriesSnapshot.append(items, to: rootItem)
        
        dataSource.apply(categoriesSnapshot, to: .categories, animatingDifferences: false)
    }
    
    //MARK: - Networking
    
    func loadCategories() async throws -> Category? {
        try await repository.fetchCategories()
        
        guard let first = await categoriesStore.categories.first else { return nil }
        
        fetchAllCategoriesInBackground()
        
        return first
    }
    
    // MARK: - Misc
    
    func getCategoryToShowBaseOn(_ title: String) async -> Category? {
        await categoriesStore.categories.first(where: {$0.title == title})
    }
    
    
    //MARK: - Private Helpers
    
    private func fetchAllCategoriesInBackground() {
        let repository = self.repository
        
        Task(priority: .background) {
            let categories = await categoriesStore.categories
            
            await withThrowingTaskGroup(of: MealResponse.self) { group in
                for category in categories.dropFirst() {
                    group.addTask {
                        return try await repository.fetchMeals(for: category)
                    }
                }
            }
        }
    }
}


struct YummyRewardsRepository {
    let apiService: any APIServiceProtocol
    let cacheService: any MealsCacheProtocol
    let categoriesStore: any CategoriesStoreProtocol
    
    // MARK: - Initializer
    
    init(
        apiService: any APIServiceProtocol = APIService.shared,
        cacheService: any MealsCacheProtocol = MealsCache.shared,
        categoriesStore: any CategoriesStoreProtocol = CategoriesStore.shared
    ){
        self.apiService = apiService
        self.cacheService = cacheService
        self.categoriesStore = categoriesStore
    }
    
    func fetchCategories() async throws {
        let response: CategoryResponse = try await apiService.fetch(endpoint: .categories)
        await categoriesStore.add(categories: response.categories)
    }
    
    func fetchMeals(for category: Category) async throws -> MealResponse {
        try await cacheService.fetchMeals(for: category)
    }
}













protocol CategoriesStoreProtocol: Actor {
    func add(category: Category)
    func add(categories: [Category])
}

final actor CategoriesStore: CategoriesStoreProtocol {
    static let shared = CategoriesStore()
    @Published private(set) var categories = [Category]()
    
    func add(category: Category) {
        categories.append(category)
    }
    
    func add(categories: [Category]) {
        self.categories.append(contentsOf: categories)
    }
}


final actor MealsStore: CategoriesStoreProtocol {
    static let shared = CategoriesStore()
    @Published private(set) var categories = [Category]()
    
    func add(category: Category) {
        categories.append(category)
    }
    
    func add(categories: [Category]) {
        self.categories.append(contentsOf: categories)
    }
}
