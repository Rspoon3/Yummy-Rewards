//
//  UserDefaults+Extension.swift
//  Yummy Rewards
//
//  Created by Richard Witherspoon on 10/2/22.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        return UserDefaults(suiteName: "group.com.buildinginbinary.Yummy-Meals")!
    }
}
