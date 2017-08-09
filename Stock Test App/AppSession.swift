//
//  AppSession.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/4/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import UIKit

enum SessionStatus {
    case preLogin
    case watchlist
    case editWatchlists
    case searchSymbol
}

/// Maintains the current user's session
struct AppSession {
    
    static var status = SessionStatus.preLogin
    /// Navigation controller set in didFinishLaunchingWithOptions
    static var navigationController: NavigationController!
    /// Watchlists that the user has saved
    static var userWatchlists = [String: Watchlist]()
    /// Watchlists that the user has saved, but in display order
    static var orderedWatchlist: [Watchlist] {
        
        var list = [Watchlist]()
        for watchlist in userWatchlists {
            list.append(watchlist.value)
        }
        list.sort { $0.displayOrder < $1.displayOrder }
        return list
    }
    /// Current watchlist name that the user has selected in the dropdown
    static var currentWatchlistName = ""
    /// Logged in User ID
    static var loggedInUserID: String?
    
}
