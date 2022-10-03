//
//  CategoryCell.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/2/22.
//


import UIKit

class CategoryCell: UICollectionViewCell {
    private let titleLabel   = UILabel()
    private var imageTask: Task<Void, Error>?
    private let imageView = UIImageView()
    private let placeholder = UIImage(systemName: "square.grid.2x2")
    
    
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
    func configure(category: Category){
        titleLabel.text = category.title
        imageTask = imageView.setAndCacheImage(from: category.thumbnail)
    }
    
    
    //MARK: - Private Helpers
    private func addViews() {
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
        stackView.spacing = 10
        
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
