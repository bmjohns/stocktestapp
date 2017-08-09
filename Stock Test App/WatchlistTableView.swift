//
//  WatchlistTableView.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/6/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import UIKit


/// Custom tableview for displaying quotes in a watchlist
final class WatchlistTableView: UITableView {
    
    
    /// Formats the price with 2 decimal places, or "--" if format was unsuccsessful
    ///
    /// - Parameter string: String to be formatted
    fileprivate func formatPrice(fromString string: String) -> String {
        
        var formattedPrice = string.formattedPriceValue()
        
        if formattedPrice == "" {
            // if format was unsuccessfull, display deafult value
            formattedPrice = AppConstants.nullDisplayValue
        }
        return formattedPrice
    }
    
}


// MARK: - UITableViewDataSource
extension WatchlistTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        if let currentWatchlist = AppSession.userWatchlists[AppSession.currentWatchlistName] {
            rows = currentWatchlist.savedQuotes.count
        }
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "WatchlistCell", for: indexPath)
                as! WatchlistCell
        
        if let quote = AppSession.userWatchlists[AppSession.currentWatchlistName]?.savedQuotes[indexPath.row] {
            cell.symbol.text = quote.symbol
            cell.price.text = formatPrice(fromString: quote.lastPrice)
            cell.ask.text = formatPrice(fromString: quote.askPrice)
            cell.bid.text = formatPrice(fromString: quote.bidPrice)
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        if let watchlist = AppSession.userWatchlists[AppSession.currentWatchlistName] {
            
            let quote = watchlist.savedQuotes[indexPath.row]
            
            AlertHandler.showAlert(withTitle: "Delete Symbol",
                                   message: "Are you sure you want to remove \(quote.symbol.uppercased()) from watchlist:\n\(watchlist.name)") { [weak self] in
                                    
                                    // If user selects continue then remove the watchlist from the table
                                    AppSession.status = .editWatchlists
                                    AppSession.userWatchlists[AppSession.currentWatchlistName]?.savedQuotes.remove(at: indexPath.row)
                                    self?.deleteRows(at: [indexPath],
                                                     with: .automatic)
                                    AppSession.status = .watchlist
            }
        }
    }
}


// MARK: - UITableViewDelegate
extension WatchlistTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
}
