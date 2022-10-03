//
//  Set+Extension.swift
//  Yummy Meals
//
//  Created by Richard Witherspoon on 10/2/22.
//

import Foundation

extension Set {
    mutating func insertOrRemove(_ element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}
