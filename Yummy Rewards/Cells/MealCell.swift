//
//  MealCell.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/1/22.
//

import UIKit

class MealCell: UICollectionViewCell {
    private let titleLabel   = UILabel()
    private var imageTask: Task<Void, Error>?
    private let imageView = UIImageView()
    private let placeholder = UIImage(systemName: "fork.knife")
    private var meal: Meal?
    
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        imageView.contentMode = .scaleAspectFit
        imageView.image = placeholder
    }
    
    
    //MARK: - Public Funcitons
    func configure(meal: Meal){
        self.meal = meal
        
        titleLabel.text = meal.title
        imageTask = imageView.setAndCacheImage(from: meal.thumbnail)
    }
    
    
    //MARK: - Private Helpers
    private func addViews() {
        let dragInteraction = UIDragInteraction(delegate: self)
        let interaction = UIContextMenuInteraction(delegate: self)
        imageView.addInteraction(dragInteraction)
        imageView.addInteraction(interaction)
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .placeholderText
        imageView.tintColor = .placeholderText
        imageView.image = placeholder
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.numberOfLines = 2
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let random = Int.random(in: 0...10)
        stackView.spacing = random.isMultiple(of: 3) ? -8 : 10
        
        contentView.addSubview(stackView)
        
        let imageViewHeight = imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 9 / 16)
        imageViewHeight.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            imageViewHeight,
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ])
    }
}

extension MealCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let meal else { return nil }
        let isFavorite = PersistenceManager.shared.favoriteMeals.map(\.id).contains(meal.id)
        
        let favorite = UIAction(title: isFavorite ? "Unfavorite" : "Favorite",
                                image: UIImage(systemName: isFavorite ? "star.fill" : "star")) { action in
            if isFavorite {
//                PersistenceManager.shared.favoriteMeals.removeAll(where: {$0.id == meal.id})
            } else {
//                PersistenceManager.shared.favoriteMeals.append(meal)
            }
        }
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            UIMenu(title: "", children: [favorite])
        }
    }
}


extension MealCell: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard
            let meal,
            let data = try? JSONEncoder().encode(meal)
        else {
            return []
        }
        
        let dataString = String(decoding: data, as: UTF8.self)
        
        let provider = NSItemProvider(object: "\(dataString)" as NSString)
        let dragItem = UIDragItem(itemProvider: provider)

        return [dragItem]
    }
}
