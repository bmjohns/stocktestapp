//
//  Quote.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/3/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation

/// Retains information about a single quote
struct Quote {
    
    var symbol = AppConstants.nullDisplayValue
    var bidPrice = AppConstants.nullDisplayValue
    var askPrice = AppConstants.nullDisplayValue
    var lastPrice = AppConstants.nullDisplayValue
    
    private let symbolIdentifier = "symbol"
    private let bidIdentifier = "bid"
    private let askIdentifier = "ask"
    private let lastPriceIdentifier = "lastPrice"
    
    /// This quote struct and its variables in the form of a string
    var jsonString: String {
        
        let data = AppUtility.convertDataToString(data: [symbolIdentifier: symbol,
                                                         bidIdentifier: bidPrice,
                                                         askIdentifier: askPrice,
                                                         lastPriceIdentifier: lastPrice])
        return data
    }
    
    // MARK: Custom initializers
    
    init(symbol:String, bidPrice:String, askPrice:String, lastPrice:String) {
        self.symbol = symbol
        self.bidPrice = bidPrice
        self.askPrice = askPrice
        self.lastPrice = lastPrice
    }
    
    init() {
        self.symbol = AppConstants.nullDisplayValue
        self.bidPrice = AppConstants.nullDisplayValue
        self.askPrice = AppConstants.nullDisplayValue
        self.lastPrice = AppConstants.nullDisplayValue

    }
    
    init(jsonString:String) {
        
        let collection = jsonString.convertToCollection()
        
        if let symbol = collection?[symbolIdentifier] {
            self.symbol = symbol
        }
        if let bidPrice = collection?[bidIdentifier] {
            self.bidPrice = bidPrice
        }
        if let askPrice = collection?[askIdentifier] {
            self.askPrice = askPrice
        }
        if let lastPrice = collection?[lastPriceIdentifier] {
            self.lastPrice = lastPrice
        }
    }

}
