//
//  UIViewController+Extension.swift
//  Yummy Meals
//
//  Created by Richard Witherspoon on 10/1/22.
//

import UIKit

extension UIViewController{
    func presentGeneralAlert(for error: Error, titled: String = "Error"){
        DispatchQueue.main.async{
            let okAction = UIAlertAction(title: "Okay", style: .cancel)
            let alertController = UIAlertController(title: titled,
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true)
        }
    }
    
    func presentGeneralAlert(title: String, message: String){
        DispatchQueue.main.async{
            let okAction = UIAlertAction(title: "Okay", style: .cancel)
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true)
        }
    }
}
