//
//  WatchlistViewController.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/3/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import UIKit
import FacebookLogin


/// View controller used to display, edit and add watchlists of quotes for the user. This is the main page of the app after login
final class WatchlistViewController: UIViewController {
    
    @IBOutlet var currentWatchlistDisplay: UILabel!
    @IBOutlet var search: UIButton!
    @IBOutlet var quotesTable: WatchlistTableView!
    @IBOutlet var watchlistHeader: UIView!
    @IBOutlet var searchView: ModalView!
    @IBOutlet var modalViewTop: NSLayoutConstraint!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var symbolTable: SymbolTableView!
    @IBOutlet var watchlistsView: UIView!
    @IBOutlet var dropDownIcon: UILabel!
    @IBOutlet var userWatchlistTable: UserWatchlistsTableView!
    
    var login: LoginButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        AppSession.status = .watchlist
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateWatchlist),
                                               name: NSNotification.Name(AppConstants.updateWatchlistNotfication),
                                               object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        // override to make status bar white
        return .lightContent
    }
    
    
    /// Updates the watchlist
    func updateWatchlist() {
        
        quotesTable.reloadData()
        updateWatchlistSelector()
    }
    
    /// Sets up the UI for the view on first load
    private func setupUI() {
        
        self.addLoginButton()
        // remove empty cells
        quotesTable.tableFooterView = UIView()
        
        quotesTable.delegate = quotesTable
        quotesTable.dataSource = quotesTable
        symbolTable.delegate = symbolTable
        symbolTable.dataSource = symbolTable
        userWatchlistTable.dataSource = userWatchlistTable
        userWatchlistTable.delegate = userWatchlistTable
        userWatchlistTable.userWatchlistsDelegate = self
        
        updateWatchlistSelector()
        modalViewTop.constant = view.frame.height
        view.bringSubview(toFront: searchView)
        
        searchTextField.delegate = self
        
    }
    
    /// Updates the watchlist dropdown selector
    private func updateWatchlistSelector() {
        
        currentWatchlistDisplay.text = AppSession.currentWatchlistName
    }
    
    /// Add the login button to the view, this should be logout when user is already logged in
    private func addLoginButton() {
        
        login = LoginButton(readPermissions: [.publicProfile])
        if let login = login {
        login.loginBehavior = .systemAccount
        login.delegate = self
        login.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(login)
        
        // Configure Constraints
        let loginLeading = login.leadingAnchor.constraint(equalTo: watchlistHeader.leadingAnchor)
        loginLeading.constant = 15
        loginLeading.isActive = true
        login.centerYAnchor.constraint(equalTo: search.centerYAnchor).isActive = true
        }
    }
    
    /// Display an error alert to the user
    fileprivate func showError() {
        
        AlertHandler.showSimpleAlert(withTitle: "Error",
                                     message: "Logout failed, please try again")
        
    }
    
    /// Updates the watchlist dropdown view
    ///
    /// - Parameter isDisplaying: true to expand and show the dropdown, false to retract and hide it
    fileprivate func updateWatchlistView(isDisplaying: Bool) {
        
        watchlistsView.isHidden = !isDisplaying
        dropDownIcon.text = !isDisplaying ? "▼": "▲"
    }
    
    @IBAction func closeSearchPressed(_ sender: UIButton) {
        
        // Dismiss keyboard
        UIApplication.shared.sendAction(#selector(AppDelegate.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
        
        searchView.updateHiddenScreen(withConstraint: modalViewTop,
                                      animateFrom: .bottom,
                                      completionBlock: { [weak self] in
                                        self?.updateWatchlist()
                                        AppSession.status = .watchlist
        })
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        
        AppSession.status = .searchSymbol

        searchView.updateHiddenScreen(withConstraint: modalViewTop,
                                      animateFrom: .bottom,
                                      completionBlock: nil)
    }
    
    @IBAction func watchlistDropdownPressed(_ sender: UIButton) {
        
        AppSession.status = watchlistsView.isHidden ? .editWatchlists : .watchlist
        
        updateWatchlistView(isDisplaying: watchlistsView.isHidden)
    }
    
    @IBAction func createWatchlistPressed(_ sender: UIButton) {
        
        // add row to let user create a new watchlist
        userWatchlistTable.addCreationRow()
    }
    
}


// MARK:- UserWatchlistCellDelegate

extension WatchlistViewController: UserWatchlistsDelegate {
    
    func watchlistChanged(toWatchlistName name: String, status: UserWatchlistStatus) {
        
        
        // watchlist has been changed so we need to reload the watchlist data
        updateWatchlist()
        
        switch status {
        case .changedWatchlists:
        break // no special action
        case .selectedWatchlist:
            AppSession.status = .watchlist
            updateWatchlistView(isDisplaying: false)
        }
    }
}

// MARK:- LoginButtonDelegate

extension WatchlistViewController: LoginButtonDelegate {
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        
        switch result {
        case .success(grantedPermissions: _, declinedPermissions: _, token: _):
            // navigate user to login page
            AppSession.navigationController.replaceAllViewControllers(withViewControllerName: AppConstants.loginViewStoryboard,
                                                                      animated: true)
            // store and reset user watchlists
            QuoteDataSourceHandler.resetAndStoreUserWatchlistsInKeychain()
        case .failed(let error):
            print(error.localizedDescription)
            showError()
        case .cancelled:
            // take no action
            break
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
        // remove login delegate to remove strong reference circle
        login?.delegate = nil
        
        // take user back to login screen
        AppSession.navigationController.replaceAllViewControllers(withViewControllerName: AppConstants.loginViewStoryboard,
                                                                  animated: true)
        RefreshTimerHandler.stopRefreshingTimer()
    }
}

// MARK: - UITextFieldDelegate

extension WatchlistViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // Workaround for iOS 9 bug where text jumps on editing
        textField.layoutIfNeeded()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var currentText = "\(textField.text ?? "")"
        if string == "" && currentText.characters.count > 0 {
            // user is deleting a character
            currentText = String(currentText.characters.dropLast())
        } else {
            // user is adding new characters
            currentText += string
        }
        // perform search
        if currentText == "" {
            DispatchQueue.main.async { [weak self] in
                // if no text, remove all data from table
                self?.symbolTable.symbolDataSource.removeAll()
                self?.symbolTable.reloadData()
            }
        } else {
            SymbolSearchHandler.fecthResults(forText: currentText) { [weak self] (response) in
                
                switch response {
                case .success(let symbols):
                    DispatchQueue.main.async {
                        self?.symbolTable.symbolDataSource = symbols
                        self?.symbolTable.reloadData()
                    }
                case .failure:
                    break // fail silently
                }
            }
        }
        return true
    }
    
}

