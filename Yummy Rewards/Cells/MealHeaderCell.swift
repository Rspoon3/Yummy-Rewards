//
//  MealHeaderCell.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/2/22.
//

import UIKit

class MealHeaderCell: UICollectionViewCell {
    private let categoryLabel = PaddedLabel(padding: 6)
    private let areaLabel = PaddedLabel(padding: 6)
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
    func configure(with meal: Meal){
        self.meal = meal
        
        categoryLabel.text = meal.category
        categoryLabel.isHidden = meal.category == nil
        
        areaLabel.text = meal.area
        areaLabel.isHidden = meal.area == nil
        
        imageTask = imageView.setAndCacheImage(from: meal.thumbnail)
    }
    
    
    //MARK: - Private Helpers
    private func addViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .placeholderText
        imageView.tintColor = .placeholderText
        imageView.image = placeholder
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        
        for label in  [categoryLabel, areaLabel] {
            label.font = .preferredFont(forTextStyle: .headline)
            label.backgroundColor = .tintColor.withAlphaComponent(0.75)
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 4
            label.textColor = .white
        }
        
        let tagsStack = UIStackView(arrangedSubviews: [categoryLabel, areaLabel])
        tagsStack.axis = .horizontal
        tagsStack.spacing = 10
        tagsStack.translatesAutoresizingMaskIntoConstraints = false
        tagsStack.alignment = .leading
        
        contentView.addSubview(imageView)
        contentView.addSubview(tagsStack)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 300),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            tagsStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            tagsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            tagsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            tagsStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
        ])
    }
}
