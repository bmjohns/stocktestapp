//
//  AppUtility.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/3/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import UIKit

struct AppNavigationUtility {
    
    /**
     Retrieves the initial view controller with the corresponding storyboard name.
     
     - parameter name: String of storyboard name.
     
     - returns: UIViewController that cooresponds to the passed storyboard name.
     */
    static func viewControllerFrom(storyBoardName name: String) -> UIViewController {
        
        // Retrieve view controller, if it does not exist throw error so we know to fix name issue
        let viewController = UIStoryboard(name: name,
                                          bundle: nil).instantiateInitialViewController()!
        
        return viewController
    }
}
