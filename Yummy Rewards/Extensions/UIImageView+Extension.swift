//
//  UIImageView+Extension.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/3/22.
//

import UIKit

extension UIImageView {
    func setAndCacheImage(from url: String) -> Task<Void, Error> {
        return Task {
            if let image = try? await ImageCache.shared.fetch(url) {
                contentMode = .scaleAspectFill
                self.image = image
            }
        }
    }
}
