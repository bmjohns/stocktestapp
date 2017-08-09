//
//  NavigationController.swift
//  Stock Test App
//
//  Created by Brett M Johnsen on 8/3/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import UIKit

/**
 UINavigationController that has convience methods for easily removing and adding view controllers
 */
class NavigationController: UINavigationController {

    // MARK: Public

    /**
     Removes all view controllers from navigation controller and adds/presents the view controller that corresponds to the passed name.

     - parameter name:     String of the storyboard that should be replacing the current view controllers in the navigation stack.
     - parameter animated: Bool true if presenting of new view controller should be animated, false if not.
     */
    func replaceAllViewControllers(withViewControllerName name: String, animated: Bool) {

        let viewController = AppNavigationUtility.viewController(fromStoryBoardName: name)
        replaceAllViewControllers(withViewController: viewController,
            animated: animated)
    }

    /**
     Removes the currently presented view controller from navigation controller and adds/presents the view controller that corresponds to the passed name.

     - parameter name:     String of the storyboard that should be replacing the presented view controller in the navigation stack.
     - parameter animated: Bool true if presenting of new view controller should be animated, false if not.
     */
    func replaceCurrentViewController(withViewControllerName name: String, animated: Bool) {

        let viewController = AppNavigationUtility.viewController(fromStoryBoardName: name)
        replaceCurrentViewController(withViewController: viewController,
            animated: animated)

    }

    /**
     Removes all view controllers from navigation controller and adds/presents the passed view controller.

     - parameter viewController:    UIViewController should be replacing the current view controllers in the navigation stack.
     - parameter animated:          Bool true if presenting of new view controller should be animated, false if not.
     */
    func replaceAllViewControllers(withViewController viewController: UIViewController, animated: Bool) {

        let viewControllers = [viewController]
        setViewControllers(viewControllers,
            animated: animated)
    }

    /**
     Removes the currently presented view controller from navigation controller and adds/presents the passed view controller.

     - parameter name:     UIViewController that should be replacing the presented view controller in the navigation stack.
     - parameter animated: Bool true if presenting of new view controller should be animated, false if not.
     */
    func replaceCurrentViewController(withViewController viewController: UIViewController, animated: Bool) {

        var viewControllers = self.viewControllers
        viewControllers.removeLast()
        viewControllers.append(viewController)
        setViewControllers(viewControllers, animated: animated)

    }

    /**
     Pushes view controller that corresponds to the passed name onto the navigation stack.

     - parameter name:     String of the storyboard that corresponds to the view controller that should be pushed to the navigation stack.
     - parameter animated: Bool true if presenting of new view controller should be animated, false if not.
     */
    func pushViewController(withStoryBoardName name: String, animated: Bool) {

        let viewController = AppNavigationUtility.viewController(fromStoryBoardName: name)
        pushViewController(viewController, animated: animated)
    }

}
