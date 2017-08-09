//
//  Watchlist.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/3/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation

/// Retains information about a single watchlist
struct Watchlist {
    
    var name: String = ""
    var savedQuotes = [Quote]() {
        didSet {
            // sort quotes by symbol
            savedQuotes.sort { $0.symbol < $1.symbol }
        }
    }
    var displayOrder = 0
    
    private let nameIdentifier = "name"
    private let savedQuotesIdentifier = "savedQuotes"
    private let displayOrderIdentifier = "displayOrder"
    private let componentSeperator = "@@"
    
    /// This watchlist struct and its variables in the form of a string
    var jsonString: String {
        
        var quoteString = ""
        for quote in savedQuotes {
            quoteString += "\(quote.jsonString)\(componentSeperator)"
        }
        
        let data = AppUtility.convertDataToString(data: [nameIdentifier: name,
                                                         savedQuotesIdentifier: quoteString,
                                                         displayOrderIdentifier: "\(displayOrder)"])
        return data
    }
    
    // MARK: Custom initializers
    
    init(name:String, savedQuotes:[Quote], displayOrder:Int) {
        
        self.name = name
        self.savedQuotes = savedQuotes
        self.displayOrder = displayOrder
    }
    
    init() {
        self.name = ""
        self.savedQuotes = [Quote]()
        self.displayOrder = 0
    }
    
    init(jsonString:String) {
        
        let collection = jsonString.convertToCollection()
        
        if let name = collection?[nameIdentifier] {
            self.name = name
        }
        if let savedQuotesString = collection?[savedQuotesIdentifier] {
            let quotesSymbols = savedQuotesString.components(separatedBy: componentSeperator)
            for quoteSymbolJSON in quotesSymbols {
                if quoteSymbolJSON != "" {
                    let newQuote = Quote(jsonString:quoteSymbolJSON)
                    self.savedQuotes.append(newQuote)
                }
            }
        }
        if let displayOrder = collection?[displayOrderIdentifier],
            let order = Int(displayOrder) {
            self.displayOrder = order
        }
    }
    
    fileprivate func sort(quotes: [Quote]) -> [Quote] {
        
        // sort quotes by symbol
        var list = [Quote]()
        for quote in savedQuotes {
            list.append(quote)
        }
        list.sort { $0.symbol < $1.symbol }
        return list
    }
}
