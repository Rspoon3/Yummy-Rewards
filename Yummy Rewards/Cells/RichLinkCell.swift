//
//  RichLinkCell.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/2/22.
//

import UIKit
import LinkPresentation


class RichLinkCell: UICollectionViewCell {
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGroupedBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Public
    func configure(with metadata: LPLinkMetadata) {
        let linkView = LPLinkView(metadata: metadata)
        linkView.translatesAutoresizingMaskIntoConstraints = false
        linkView.isUserInteractionEnabled = false
        contentView.addSubview(linkView)
        
        NSLayoutConstraint.activate([
            linkView.topAnchor.constraint(equalTo: contentView.topAnchor),
            linkView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            linkView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            linkView.trailingAnchor.constraint(equalTo:  contentView.trailingAnchor, constant: -15),
        ])
    }
}
