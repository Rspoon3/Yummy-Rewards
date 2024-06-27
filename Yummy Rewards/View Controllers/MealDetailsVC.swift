//
//  MealDetailsVC.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/1/22.
//

import UIKit
import LinkPresentation
import Networking

class MealDetailsVC: UIViewController {
    private var meal: Meal
    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>! = nil
    private var collectionView: UICollectionView! = nil
    private var usedIngredients = Set<Ingredient>()
    private let persistenceManager = PersistenceManager.shared
    private let spinner = YummySpinner()
    
    enum Section: String {
        case main, instructions, ingredients, richLink
    }
    
    
    //MARK: - Initializer
    init(meal: Meal) {
        self.meal = meal
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        
        configureNavView()
        configureCollectionView()
        configureDataSource()
        loadDetails()
    }
    
    private func configureNavView() {
        let isFavorite = persistenceManager.favoriteMeals.map(\.id).contains(meal.id)
        
        navigationItem.title = meal.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(systemName: isFavorite ? "star.fill" : "star"),
                                                            primaryAction: .init(handler: { [weak self] _ in
            guard let self = self else { return }
            if isFavorite {
                self.persistenceManager.favoriteMeals.removeAll(where: {$0.id == self.meal.id})
            } else {
                self.persistenceManager.favoriteMeals.append(self.meal)
            }
            
            self.configureNavView()
        }))
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = self?.dataSource.sectionIdentifier(for: sectionIndex) else {
                return nil
            }
            
            switch section {
            case .main:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .estimated(200))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
                return NSCollectionLayoutSection(group: group)
            case .instructions, .ingredients:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = .supplementary
                return .list(using: config, layoutEnvironment: layoutEnvironment)
            case .richLink:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalWidth(9 / 16))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
                let section =  NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 15
                
                return section
            }
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    
    //MARK: - Private Helpers
    private func loadDetails() {
        Task {
            spinner.addTo(view)
            
            do {
                let response: MealResponse = try await APIService.shared.fetch(endpoint: .details(mealID: meal.id))
                if let meal = response.meals.first {
                    self.meal = meal
                }
                applyInitialSnapshot()
            } catch {
                presentGeneralAlert(for: error)
            }
            
            spinner.removeFromSuperview()
        }
    }
    
    
    //MARK: - Data Source
    private func createHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        UICollectionView.SupplementaryRegistration <UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            guard
                let self = self,
                let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section]
            else {
                return
            }
            
            var configuration: UIListContentConfiguration!
            configuration = UIListContentConfiguration.prominentInsetGroupedHeader()
            configuration.text = section.rawValue.capitalized
            configuration.textProperties.font = .preferredFont(forTextStyle: .headline)
            headerView.contentConfiguration = configuration
        }
    }
    
    private func configureDataSource() {
        let headerRegistration = createHeaderRegistration()

        let textCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { (cell, indexPath, text) in
            var content = cell.defaultContentConfiguration()
            content.text = text
            cell.contentConfiguration = content
        }
        
        let ingredientCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Ingredient> { [weak self] (cell, indexPath, ingredient) in
            guard let self = self else { return }
            let hasUsed = self.usedIngredients.contains(ingredient)
            
            var content = cell.defaultContentConfiguration()
            
            if let measurement = ingredient.measurement {
                content.text = "\(ingredient.title) - \(measurement)"
            } else {
                content.text = ingredient.title
            }
            
            content.textProperties.color = hasUsed ? .placeholderText : .label
            content.image = UIImage(systemName: hasUsed ? "checkmark.circle" : "circle")
            content.imageProperties.tintColor = hasUsed ? .placeholderText : .tintColor
            cell.contentConfiguration = content
        }
        
        let metaDataCellRegistration = UICollectionView.CellRegistration<RichLinkCell, LPLinkMetadata> { (cell, indexPath, metadata) in
            cell.configure(with: metadata)
        }
        
        let mealHeaderCellRegistration = UICollectionView.CellRegistration<MealHeaderCell, Meal> { (cell, indexPath, meal) in
            cell.configure(with: meal)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            if let ingredient = item as? Ingredient {
                return collectionView.dequeueConfiguredReusableCell(using: ingredientCellRegistration, for: indexPath, item: ingredient)
            } else if let metadata = item as? LPLinkMetadata {
                return collectionView.dequeueConfiguredReusableCell(using: metaDataCellRegistration, for: indexPath, item: metadata)
            } else if let text = item as? String {
                return collectionView.dequeueConfiguredReusableCell(using: textCellRegistration, for: indexPath, item: text)
            } else if let meal = item as? Meal {
                return collectionView.dequeueConfiguredReusableCell(using: mealHeaderCellRegistration, for: indexPath, item: meal)
            } else {
                fatalError("This cell is not supported")
            }
        }
        
        dataSource?.supplementaryViewProvider = { [weak self] (view, kind, index) in
            return self?.collectionView.dequeueConfiguredReusableSupplementary(using:headerRegistration, for: index)
        }
        
    }
    
    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections([.main])
        snapshot.appendItems([meal])

        if let instructions = meal.instructions {
            snapshot.appendSections([.instructions])
            snapshot.appendItems([instructions.replacingOccurrences(of: "\n", with: "\n\n")])
        }
        
        if let ingredients = meal.ingredients, !ingredients.isEmpty {
            snapshot.appendSections([.ingredients])
            snapshot.appendItems(ingredients)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)

        
        if let youtube = meal.youtube,
           let url = URL(string: youtube)  {
            Task(priority: .userInitiated) {
                let contents = try String(contentsOf: url, encoding: .ascii)
                guard !contents.contains("playerErrorMessageRenderer") else {
                    return
                }
                
                let metadata = try await LPMetadataProvider().startFetchingMetadata(for: url)
                
                if !snapshot.sectionIdentifiers.contains(.richLink){
                    snapshot.appendSections([.richLink])
                }
                
                snapshot.appendItems([metadata])
                await dataSource.apply(snapshot, animatingDifferences: false)
            }
        }
        
        if let source = meal.source,
           let url = URL(string: source)  {
            Task(priority: .userInitiated) {
                let metadata = try await LPMetadataProvider().startFetchingMetadata(for: url)
                
                if !snapshot.sectionIdentifiers.contains(.richLink){
                    snapshot.appendSections([.richLink])
                }
                
                snapshot.appendItems([metadata])
                await dataSource.apply(snapshot, animatingDifferences: false)
            }
        }
    }
}


//MARK: - UICollectionViewDelegate
extension MealDetailsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if indexPath.item == 2 { exit(1) }
        
        if let ingredient = dataSource.itemIdentifier(for: indexPath) as? Ingredient {
            usedIngredients.insertOrRemove(ingredient)
            
            var snapshot = dataSource.snapshot()
            snapshot.reconfigureItems([ingredient])
            dataSource.apply(snapshot, animatingDifferences: true)
        } 
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        
        return section == .ingredients
    }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct MealDetailsVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            let vc = MealDetailsVC(meal: .apamBalik!)
            return UINavigationController(rootViewController: vc)
        }
    }
}
#endif
