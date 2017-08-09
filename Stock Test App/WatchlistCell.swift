//
//  WatchlistCell.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/6/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import UIKit

/// Custom cell for displaying data in quotes for the watchlist
final class WatchlistCell: UITableViewCell {
    
    @IBOutlet var symbol: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var ask: UILabel!
    @IBOutlet var bid: UILabel!
}
