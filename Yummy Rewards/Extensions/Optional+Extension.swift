//
//  Optional+Extension.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/1/22.
//

import Foundation


extension Optional where Wrapped: Collection {
    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }
}