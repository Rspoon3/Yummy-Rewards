//
//  SidebarVC.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/1/22.
//

import UIKit

class SidebarVC: UIViewController {
    private var collectionView: UICollectionView! = nil
    private let spinner = YummySpinner()
    private let viewModel = SidebarVCViewModel()
    
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureCollectionView()
        viewModel.configureDataSource(for: collectionView)
        viewModel.applyMainSnapshots()
        loadCategories()
    }
    
    private func loadCategories() {
        Task {
            spinner.addTo(view)
            defer {  spinner.removeFromSuperview() }
            
            do {
                guard let categoryToShow = try await viewModel.loadCategories() else { return }
                show(categoryToShow)
                collectionView.selectItem(
                    at: .init(item: 1, section: 1),
                    animated: false,
                    scrollPosition: .bottom
                )
            } catch {
                presentGeneralAlert(for: error)
            }
        }
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
    

    //MARK: Data Source
    
    private func show(_ category: Category) {
        guard viewModel.selectedCategory != category else { return }
        
        viewModel.selectedCategory = category
        let nav = UINavigationController(rootViewController: MealsVC(viewType: .category(category: category)))
        navigationController?.showDetailViewController(nav, sender: nil)
    }
}


//MARK: - UICollectionViewDelegate
extension SidebarVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let item = viewModel.dataSource.itemIdentifier(for: indexPath),
            let section = viewModel.dataSource.snapshot().sectionIdentifier(containingItem: item)
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
            Task {
                guard let category = await viewModel.getCategoryToShowBaseOn(item.title) else { return }
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
