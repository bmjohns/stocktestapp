//
//  String+StringUtility.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/3/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation

extension String {
    
    /**
     convertToDictionary helps to convert Json Object string to a collection of strings
     
     - return NSDictionary object of Json String
     */
    func convertToCollection() -> [String: String]? {
        if let data = data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            } catch let error as NSError {
                print(error)
            }
        }
        
        return nil
    }
    
    ///  Formats the given string as USD. Inserts necessary characters such as dollar sign ($), commas (,), and decimals (.)
    ///
    /// - returns: USD-formatted string with inserted monetary symbol, comma-delimiters, and a cents-delimiter
    func formattedPriceValue() -> String {
        
        var currencyValue:String = ""
        if let double = Double(self) {
            let displayNumbers = NSNumber(value: double)
            if let value = AppUtility.priceNumberFormatter.string(from: displayNumbers) {
                currencyValue = value
            }
        }
        return currencyValue
    }
}
