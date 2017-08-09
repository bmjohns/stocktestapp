//
//  AppDelegate.swift
//  Stock Test App
//
//  Created by Brett M Johnsen on 8/3/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import UIKit
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // connect to get proper delegate calls from facebook
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        processUserAppSession()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // connect to get proper delegate calls from facebook
        let handled = SDKApplicationDelegate.shared.application(app, open: url, options: options)
        return handled
    }
    
    
    /// Prepare user's session based on stored data
    private func processUserAppSession() {
        
        // determine root view controller by users login status
        let presentingViewController:String
        if let currentToken = AccessToken.current,
            let userID = currentToken.userId {
            presentingViewController = AppConstants.watchlistStoryboard
            // setup user session by fetching data for stored watchlists and symbols
            AppSession.loggedInUserID = userID
            QuoteDataSourceHandler.loadFromKeychain()
            QuoteDataSourceHandler.refreshWatchlistDataForCurrentUser(completion: { (response) in
                
                switch response {
                case .success:
                    DispatchQueue.main.async {
                        RefreshTimerHandler.scheduleToStartTimer()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.updateWatchlistNotfication),
                                                        object: nil)
                    }
                case .failure:
                    break // fail silently
                    
                }
            })
        } else {
            // if no access token exists then user must login first
            presentingViewController = AppConstants.loginViewStoryboard
        }
        AppSession.navigationController = window?.rootViewController as! NavigationController
        AppSession.navigationController.pushViewController(withStoryBoardName: presentingViewController,
                                                           animated: true)
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        // save data in keychain
        QuoteDataSourceHandler.resetAndStoreUserWatchlistsInKeychain()
    }
}

