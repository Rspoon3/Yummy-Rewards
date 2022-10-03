//
//  SelectCategoryVC.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/2/22.
//

import UIKit

class SelectCategoryVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let placeholder = EmptyPlaceholderView(symbol: "square.grid.2x2",
                                               text: "Select a category")
        placeholder.addTo(view)
    }
}
