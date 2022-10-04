//
//  SplitVC.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/1/22.
//

import UIKit
import Networking

class SplitVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSplitVC()
    }
    
    private func configureSplitVC(){
        let split = UISplitViewController(style: .doubleColumn)
        addChild(split)
        view.addSubview(split.view)
        split.view.frame = view.bounds
        split.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        split.didMove(toParent: self)
        split.preferredSplitBehavior = .tile
        split.preferredDisplayMode = .oneBesideSecondary
        
        split.setViewController(SidebarVC(), for: .primary)
        split.setViewController(SelectCategoryVC(), for: .secondary)
        split.setViewController(TabVC(), for: .compact)
    }
}
