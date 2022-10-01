//
//  SplitVC.swift
//  Yummy Meals
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
//        split.preferredDisplayMode = .oneBesideSecondary
//        split.preferredSplitBehavior = .tile
        
        let detailsNav = UINavigationController(rootViewController: ColorVC(color: .systemBlue))
        split.setViewController(SidebarVC(), for: .primary)
        split.setViewController(detailsNav, for: .secondary)
    }
}


class ColorVC: UIViewController {
    let color: UIColor
    
    init(color: UIColor) {
        self.color = color
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = color
    }
}
