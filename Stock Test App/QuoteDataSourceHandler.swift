//
//  QuoteDataSourceHandler.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/4/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import Alamofire


/// Possible responses from fetching quotes from the data source
///
/// - success: Quotes that were fetched
/// - failure: Quotes were not able to be fetched
enum QuoteDataSourceResponse {
    case success([Quote])
    case failure
}


/// Possible responses from refreshing quotes data in watchlists from the data source
///
/// - success: Refresh was successful
/// - failure: Refresh was unsuccessful
enum WatchlistDataSourceResponse {
    case success
    case failure
}

typealias QuoteCompletionHandler = (QuoteDataSourceResponse) -> Void
typealias WatchlistRefreshCompletionHandler = (WatchlistDataSourceResponse) -> Void


/// Handkes calling and parsing of quotes from data source service
struct QuoteDataSourceHandler {
    
    static private var isCurrentlyRefreshing = false
    
    static let yahooFinanceURL = "http://finance.yahoo.com/d/quotes.csv?f=sabl1&s="
    
    /// Refreshes all the quote data saved in the current logged in user's watchlists
    ///
    /// - Parameter completion: success if data was refreshed, failure if it was not
    static func refreshWatchlistDataForCurrentUser(completion: WatchlistRefreshCompletionHandler?) {
        
        // TODO: Change this to get non-duplicate quotes at once, then set in watchlist instead of stepping through and fetching each watchlist
        
        if let _ = AppSession.loggedInUserID,
            !isCurrentlyRefreshing {
            
            isCurrentlyRefreshing = true
            recursivelyFetchQuotesForWatchlists(currentWatchlistIndex: 0,
                                                completion: {
                                                    self.isCurrentlyRefreshing = false
                                                    completion?(.success)
            })
        } else {
            completion?(.failure)
        }
    }
    
    
    /// Adds a quote to the watchlist, also updates the data of the quotes in that watchlist
    ///
    /// - Parameters:
    ///   - quote: Quote that should be added to watchlist
    ///   - watchlist: Watchlist that the quote should be added to
    static func add(quote: Quote, toWatchlist watchlist: Watchlist) {
        
        var updatedWatchList = watchlist
        updatedWatchList.savedQuotes.append(quote)
        updateQuotes(forWatchlist: updatedWatchList, completion: nil)
    }
    
    
    /// Loads watchlists and quotes from the user's keychain
    static func loadFromKeychain() {
        
        if let user = AppSession.loggedInUserID {
            let watchlistData = KeychainHelper.getData(fromUser: user)
            AppSession.userWatchlists.removeAll()
            AppSession.currentWatchlistName = ""
            
            for watchlistCollection in watchlistData {
                let newWatchlist = Watchlist(jsonString: watchlistCollection.value)
                AppSession.userWatchlists[newWatchlist.name] = newWatchlist
            }
            if let name = AppSession.orderedWatchlist.first?.name {
                AppSession.currentWatchlistName = name
            }
        }
    }
    
    
    /// Resets all cached memory about watchlists, and stores them in the keychain for later use
    static func resetAndStoreUserWatchlistsInKeychain() {
        
        if let user = AppSession.loggedInUserID {
            
            var watchlistKeychainCollection = [String: String]()
            for watchlist in AppSession.userWatchlists {
                watchlistKeychainCollection[watchlist.key] = watchlist.value.jsonString
                KeychainHelper.save(data: watchlistKeychainCollection,
                                    forUser: user)
            }
            AppSession.userWatchlists.removeAll()
        }
        
    }
    
    
    /// Recursively fetches quotes for each watchlists, will only return when all watchlists have been fetched.
    ///
    /// - Parameters:
    ///   - currentWatchlistIndex: Current index of watchlist that is getting its quotes refreshed
    ///   - completion: Called when quotes are finished being fetched
    private static func recursivelyFetchQuotesForWatchlists(currentWatchlistIndex: Int, completion: (()->())?) {
        
        var watchlistIndex = currentWatchlistIndex
        if AppSession.orderedWatchlist.count > watchlistIndex {
            self.updateQuotes(forWatchlist: AppSession.orderedWatchlist[watchlistIndex],
                              completion: { (response) in
                                watchlistIndex += 1
                                if watchlistIndex < AppSession.orderedWatchlist.count {
                                    self.recursivelyFetchQuotesForWatchlists(currentWatchlistIndex: watchlistIndex, completion: completion)
                                }
                                else {
                                    completion?()
                                }
            })
        } else {
            completion?()
        }
    }
    
    
    /// Updated the quotes for a single watchlist
    ///
    /// - Parameters:
    ///   - watchlist: Watchlist that is getting its qutoes updated
    ///   - completion: Called when quotes have been updated
    static func updateQuotes(forWatchlist watchlist: Watchlist, completion: WatchlistRefreshCompletionHandler?) {
        
        QuoteDataSourceHandler.fecthInfo(forQuotes: watchlist.savedQuotes,
                                         completionHandler: { (response) in
                                            switch response {
                                            case .success(let quotes):
                                                var updatedWatchList = watchlist
                                                updatedWatchList.savedQuotes = quotes
                                                AppSession.userWatchlists[updatedWatchList.name] = updatedWatchList
                                                // perform completion if one exists
                                                completion?(.success)
                                            case .failure:
                                                completion?(.failure)
                                            }
        })
    }
    
    
    /// Downloads quote info as csv, and parses into structs
    ///
    /// - Parameters:
    ///   - quotes: Quotes with symbols to fetch data for
    ///   - completionHandler: success with quote structs, failure if unsuccessul
    private static func fecthInfo(forQuotes quotes: [Quote], completionHandler: @escaping QuoteCompletionHandler) {
        
        let requestURL = createRequestURL(fromQuotes: quotes)
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download(requestURL, to: destination).response { response in
            
            if let path = response.destinationURL?.path {
                if response.error == nil {
                    if let contents = try? String(contentsOfFile: path,
                                                  encoding: String.Encoding.utf8) {
                        let csvContent = CSwiftV(with: contents)
                        // there are no headers, so we combine headers and rows to get all data
                        var dataArray = csvContent.rows
                        dataArray.append(csvContent.headers)
                        var quotes = [Quote]()
                        for data in dataArray {
                            // columns are symbol, ask, bid, and price in that order
                            if data.count >= 4 {
                                quotes.append(Quote(symbol: data[0],
                                                    bidPrice: data[1],
                                                    askPrice: data[2],
                                                    lastPrice: data[3]))
                            }
                        }
                        completionHandler(.success(quotes))
                    }
                } else {
                    completionHandler(.failure)
                }
                // remove temporary file
                try? FileManager.default.removeItem(atPath: path)
            } else {
                completionHandler(.failure)
            }
        }
    }
    
    
    /// Creates the url needed to fetch quote info
    ///
    /// - Parameter quotes: Quotes with symbols that need to be fetched
    /// - Returns: full url needed for request
    private static func createRequestURL(fromQuotes quotes: [Quote]) -> String {
        
        var url = yahooFinanceURL
        for quote in quotes {
            
            url += "\(quote.symbol)+"
        }
        return url
    }
}
