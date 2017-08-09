//
//  RefreshTimerHandler.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/8/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation

/// Handles starting and stoping the watchlist refresh timer
final class RefreshTimerHandler: NSObject {
    
    fileprivate static var refreshTimer: Timer?
    fileprivate static var scheduleTimer: Timer?
    
    
    /// Starts refresh timer after 10 seconds so user has steady experience when first starting app
    static func scheduleToStartTimer() {
        
        stopScheduleTimer()
        
        scheduleTimer = Timer.scheduledTimer(timeInterval: 10,
                                             target: self,
                                             selector: #selector(startTimer),
                                             userInfo: nil,
                                             repeats: false)
        
    }
    
    /// Stops the refresh timer
    static func stopRefreshingTimer() {
        
        if let timer = refreshTimer {
            timer.invalidate()
            refreshTimer = nil
        }
    }
    
    /// Stops the schedule timer
    static func stopScheduleTimer() {
        
        if let timer = scheduleTimer {
            timer.invalidate()
            scheduleTimer = nil
        }
    }
    
    
    /// starts refresh timer to fire every 5 seconds
    @objc fileprivate static func startTimer() {
        
        stopRefreshingTimer()
        
        refreshTimer = Timer.scheduledTimer(timeInterval: 5,
                                            target: self,
                                            selector: #selector(refreshQuotes),
                                            userInfo: nil,
                                            repeats: true)
        
    }
    
    
    /// Refreshes the quotes
    @objc fileprivate static func refreshQuotes() {
        
        if AppSession.status == .watchlist {
            // only update watchlist if user is on watchlist page
            QuoteDataSourceHandler.refreshWatchlistDataForCurrentUser{ (response) in
                
                switch response {
                case .success:
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.updateWatchlistNotfication),
                                                        object: nil)
                    }
                case .failure:
                    break // fail silently
                }
            }
        }
    }
    
}
