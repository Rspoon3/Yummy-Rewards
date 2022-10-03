//
//  EmptyPlaceholderView.swift
//  Yummy Meals
//
//  Created by Richard Witherspoon on 10/2/22.
//

import UIKit

class EmptyPlaceholderView: UIView {
    let symbol: String
    let text: String
    
    
    //MARK: - Initializer
    init(symbol: String, text: String){
        self.symbol = symbol
        self.text = text
        super.init(frame: .zero)
        
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTo(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    //MARK: - Private Functions
    private func configureViews(){
        guard let image = UIImage(systemName: symbol)?.applyingSymbolConfiguration(.init(pointSize: 80)) else {
            return
        }
        
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .placeholderText
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .preferredFont(forTextStyle: .title2)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.textColor = .gray
        
        let stack = UIStackView(arrangedSubviews: [imageView, textLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct EmptyPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            UIViewPreview {
                return EmptyPlaceholderView(symbol: "fork.knife",
                                            text: "No files available")
            }
        }
    }
}
#endif

