//
//  UserWatchlistsTableView.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/7/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import UIKit


/// User Watchlist action types
///
/// - changedWatchlists: current selected list has been changed
/// - selectedWatchlist: displayed watchlist list selection has changed
enum UserWatchlistStatus {
    case changedWatchlists
    case selectedWatchlist
}


/// Delegate for User's Watchlists table view
protocol UserWatchlistsDelegate: class {
    
    
    /// Delegate called when the watchlist has changed
    ///
    /// - Parameters:
    ///   - name: String of watchlist name that changed
    ///   - status: Status of the change that occured
    func watchlistChanged(toWatchlistName name: String, status: UserWatchlistStatus)
}

/// Custom table that displays a list of watchlists the user has saved
final class UserWatchlistsTableView: UITableView {
    
    fileprivate var newListCount = 1
    fileprivate var isAddingNewList = false
    /// Creates default list name for user when they create a new list
    fileprivate var newListName: String {
        
        let newName = "New List \(newListCount)"
        newListCount += 1
        
        return newName
    }
    weak var userWatchlistsDelegate: UserWatchlistsDelegate?
    
    // Adds a new watchlist item and allows user to edit it
    func addCreationRow() {

        isAddingNewList = true
        
        let newWatchlist = Watchlist(name: "\(newListName)",
                                     savedQuotes: [Quote](),
                                     displayOrder: AppSession.orderedWatchlist.count)
        AppSession.userWatchlists[newWatchlist.name] = newWatchlist
        reloadData()
    }
}


// MARK: - UITableViewDataSource

extension UserWatchlistsTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = AppSession.orderedWatchlist.count
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "UserWatchlistCell", for: indexPath)
                as! UserWatchlistCell
        
        //setup cell
        let watchlist = AppSession.orderedWatchlist[indexPath.row]
            cell.name.text = watchlist.name
            cell.nameEditMode.text = watchlist.name
            cell.delegate = self
            cell.nameEditMode.delegate = cell
        
        // if new list, enable edit mode by default
        if isAddingNewList && indexPath.row == AppSession.orderedWatchlist.count - 1 {
            cell.updateEditMode()
            isAddingNewList = false
        }
        
        return cell;
    }
}

// MARK: - UITableViewDelegate

extension UserWatchlistsTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedWatchlist = AppSession.orderedWatchlist[indexPath.row]
        AppSession.currentWatchlistName = selectedWatchlist.name
        userWatchlistsDelegate?.watchlistChanged(toWatchlistName: selectedWatchlist.name,
                                                 status: .selectedWatchlist)
    }
}

// MARK: - UserWatchlistCellDelegate

extension UserWatchlistsTableView: UserWatchlistCellDelegate {
    
    func deletePressed(watchlistName: String) {
        
            AppSession.userWatchlists.removeValue(forKey: watchlistName)
            reloadData()
        
        userWatchlistsDelegate?.watchlistChanged(toWatchlistName: watchlistName,
                                                 status: .changedWatchlists)

    }
    
    func nameEdited(fromName oldName: String, toName newName: String?) {
        
        let replacementName = newName != nil ? newName : ""
        if AppSession.currentWatchlistName == oldName {
            AppSession.currentWatchlistName = replacementName!
        }
        userWatchlistsDelegate?.watchlistChanged(toWatchlistName: replacementName!,
                                                 status: .changedWatchlists)
    }
}
