//
//  AlertHandler.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/3/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import UIKit


/// Handles displaying alerts on the root view controller
struct AlertHandler {
    
    
    /// Present alert on root view controller with Ok button to dismiss
    ///
    /// - Parameters:
    ///   - title: String title that will be displayed on alert
    ///   - message: String message that will display on alert
    static func showSimpleAlert(withTitle title:String, message:String) {
        
        showAlert(withTitle: title,
                  message: message,
                  buttonAction: nil)
    }
    
    /// Present alert on root view controller with a button, button action, and cacnel button
    ///
    /// - Parameters:
    ///   - title: String title that will be displayed on alert
    ///   - message: String message that will display on alert
    static func showAlert(withTitle title:String, message:String, buttonAction: (()->())?) {

        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        if let _ = buttonAction {
            // if button action was set, create cancel button
            let action = UIAlertAction(title: "Cancel",
                                       style: .cancel,
                                       handler: nil)
            alertController.addAction(action)
        }
        
        let action = UIAlertAction(title: "Ok",
                                   style: .default,
                                   handler: { (action: UIAlertAction) in
                                    buttonAction?()
        })
        
        alertController.addAction(action)
        
        AppSession.navigationController.present(alertController,
                                                animated: true,
                                                completion: nil)

    }
}
