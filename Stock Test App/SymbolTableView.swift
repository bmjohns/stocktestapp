//
//  SymbolTableView.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/7/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import UIKit

/// Custom tableview for displaying symbols when searching data
class SymbolTableView: UITableView {
    
    var symbolDataSource = [Symbol]()
}

// MARK: - UITableViewDataSource

extension SymbolTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = symbolDataSource.count
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "SymbolCell", for: indexPath)
                as! SymbolCell
        
        let symbol = symbolDataSource[indexPath.row]
        cell.symbol.text = symbol.name
        cell.nameDescription.text = symbol.fullNameDescription
        
        return cell;
    }
}

// MARK: - UITableViewDelegate

extension SymbolTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let symbolName = symbolDataSource[indexPath.row].name {
            var quote = Quote()
            quote.symbol = symbolName
            if let currentList = AppSession.userWatchlists[AppSession.currentWatchlistName] {
                var isAlreadyAdded = false
                for quote in currentList.savedQuotes {
                    if quote.symbol == symbolName {
                        isAlreadyAdded = true
                        break
                    }
                }
                if isAlreadyAdded {
                    AlertHandler.showSimpleAlert(withTitle: "Oops!",
                                                 message: "That quote is already in watchlist named:\n\(AppSession.currentWatchlistName)")
                } else {
                    AlertHandler.showSimpleAlert(withTitle: "Added!",
                                                 message: "That quote has been added to watchlist named:\n\(AppSession.currentWatchlistName)")
                    QuoteDataSourceHandler.add(quote: quote,
                                               toWatchlist: currentList)
                }
                tableView.deselectRow(at: indexPath,
                                      animated: true)
            }
        }
    }
}
