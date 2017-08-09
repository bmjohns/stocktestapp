//
//  ViewController.swift
//  Stock Test App
//
//  Created by Brett M Johnsen on 8/3/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

/// Displays a page for the user to login
final class LoginViewController: UIViewController {
    
    @IBOutlet var loginPrompt: UILabel!
    
    var loginEntry: LoginButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add login button to view
        addLoginButton()
        
        AppSession.status = .preLogin
    }
    
    /// Add the login button to the view
    private func addLoginButton() {
        
        loginEntry = LoginButton(readPermissions: [.publicProfile])
        if let loginEntry = loginEntry {
            loginEntry.loginBehavior = .systemAccount
            loginEntry.delegate = self
            loginEntry.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(loginEntry)
            
            // Configure Constraints
            let loginTop = loginEntry.topAnchor.constraint(equalTo: loginPrompt.bottomAnchor)
            loginTop.constant = 15
            loginTop.isActive = true
            loginEntry.centerXAnchor.constraint(equalTo: loginPrompt.centerXAnchor).isActive = true
        }
    }
    
    
    /// Handle login success scenario by saving data if applicable
    ///
    /// - Parameter user: String of user id
    fileprivate func handleLoginSuccess(withUser user: String, andUserID userID:String) {
        
        AppSession.loggedInUserID = userID
        
        let userData = KeychainHelper.getData(fromUser: userID)
        if userData.count > 0 {
            // if data exists, clear and load it from keychain for user
            QuoteDataSourceHandler.loadFromKeychain()
            // if user already logged in then fetch current qoute info for their watchlists
            fetchWatchlists()
        } else {
            // if user has not logged in yet, create their first watchlist
            var appleQuote = Quote()
            appleQuote.symbol = "AAPL"
            var googleQuote = Quote()
            googleQuote.symbol = "GOOG"
            var microsoftQuote = Quote()
            microsoftQuote.symbol = "MSFT"
            
            let firstWatchlist = Watchlist(name: "\(user)'s first list",
                savedQuotes: [appleQuote, googleQuote, microsoftQuote],
                displayOrder: 0)
            AppSession.userWatchlists = [firstWatchlist.name: firstWatchlist]
            AppSession.currentWatchlistName = firstWatchlist.name
            fetchWatchlists()
        }
    }
    
    
    /// Fetches the user's watchlists, and on success takes them to the watchlist page
    private func fetchWatchlists() {
        
        QuoteDataSourceHandler.refreshWatchlistDataForCurrentUser { [weak self] (response) in
            
            if response == .success {
                // remove facebook login delegate  to remove strong reference circle
                self?.loginEntry?.delegate = nil
                // take user to watchlist page
                AppSession.navigationController.replaceCurrentViewController(withViewControllerName: AppConstants.watchlistStoryboard,
                                                                             animated: true)
                RefreshTimerHandler.scheduleToStartTimer()
            }
        }
        
    }
    
    /// Display an error alert to the user
    fileprivate func showError() {
        
        AlertHandler.showSimpleAlert(withTitle: "Error",
                                     message: "Login failed, please try again")
        
    }
    
}

// MARK:- LoginButtonDelegate

extension LoginViewController: LoginButtonDelegate {
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        
        switch result {
        case .success(grantedPermissions: _, declinedPermissions: _, token: let token):
            
            AppUtility.facebookUserName(completion: { [weak self] (response) in
                switch response {
                case .success(let name):
                    DispatchQueue.main.async {
                        if let userId = token.userId {
                            self?.handleLoginSuccess(withUser: name,
                                                     andUserID: userId)
                        }
                    }
                case .failure:
                    DispatchQueue.main.async {
                        self?.showError()
                    }
                }
            })
        case .failed(let error):
            print(error.localizedDescription)
            showError()
        case .cancelled:
            // take no action
            break
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
        QuoteDataSourceHandler.resetAndStoreUserWatchlistsInKeychain()
        
        //User logged out so set to nil
        AppSession.loggedInUserID = nil
    }
}

