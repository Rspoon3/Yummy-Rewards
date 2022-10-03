//
//  Bundle+Extension.swift
//  Yummy Meals
//
//  Created by Richard Witherspoon on 10/1/22.
//

import Foundation

public extension Bundle {
    static let appTitle   = main.infoDictionary?["CFBundleName"] as? String
    
    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Error trying to decode \(T.self)")
            print(error)
            fatalError(error.localizedDescription)
        }
    }
}
