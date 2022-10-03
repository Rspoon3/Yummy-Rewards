//
//  UICollectionViewLayout+Extension.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/3/22.
//

import UIKit

extension UICollectionViewLayout {
    static var yummyGrid: UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex: Int,
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
    }
}
