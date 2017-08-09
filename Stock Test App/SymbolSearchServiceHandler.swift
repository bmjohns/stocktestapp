//
//  QuoteDataSourceHandler.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/4/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import Alamofire


/// Possible responses from searching for symbols from the data source
///
/// - success: Array of Symbols found
/// - failure: Symbols could not be fetched
enum SymbolSearchResponse {
    case success([Symbol])
    case failure
}

typealias SymbolSearchCompletionHandler = (SymbolSearchResponse) -> Void

/// Handles fetching and parsing symbol search results from service
struct SymbolSearchHandler {
    
    static let searchURL = "https://trade.tastyworks.com/symbol_search/search/"
    
    
    /// Fetch results for searching for symbols
    ///
    /// - Parameters:
    ///   - text: String that should be searched for
    ///   - completionHandler: success with symbols, or failure when service/ parsing fails
    static func fecthResults(forText text: String, completionHandler: @escaping SymbolSearchCompletionHandler) {
        
        let requestURL = "\(searchURL)\(text.uppercased())"
        
        Alamofire.request(requestURL).responseJSON { response in
            
            var symbolResponseArray = [Symbol]()
            if let dataArray = response.result.value as? Array<Any> {
                for data in dataArray {
                    if let symbolArray = data as? Array<String>,
                        symbolArray.count >= 3 {
                        // columns are symbol, description name and type in that order
                        let newSymbol = Symbol(name: symbolArray[0],
                                               fullNameDescription: symbolArray[1],
                                               type: symbolArray[2])
                        symbolResponseArray.append(newSymbol)
                    }
                }
                completionHandler(.success(symbolResponseArray))
            } else {
                completionHandler(.failure)
            }
        }
        
    }
    
}
