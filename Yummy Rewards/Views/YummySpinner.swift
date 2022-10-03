//
//  YummySpinner.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/1/22.
//

import UIKit

class YummySpinner: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Public
    func addTo(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(self)
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            heightAnchor.constraint(equalToConstant: 50),
            widthAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    
    //MARK: - Private Helpers
    private func addViews() {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .tintColor
        spinner.startAnimating()
        
        backgroundColor = .systemGroupedBackground
        layer.masksToBounds = true
        layer.cornerRadius = 4
        
        addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
