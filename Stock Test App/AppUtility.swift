//
//  AppUtility.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/3/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import FacebookCore


/// Reponses for trying to fetch user name from facebook sdk
///
/// - success: Name was succesfully retrieved
/// - failure: Name could not eb retrieved
enum FacebookNameResponse {
    case success(String)
    case failure
}

typealias FacebookNameCompletionHandler = (FacebookNameResponse) -> Void


/// Useful methods that are used in multiple locations in the app
struct AppUtility {
    
    
    /// converts a collection of strings to a single json string
    ///
    /// - Parameter data: collection of strings
    /// - Returns: string in json format
    static func convertDataToString(data: [String: String]) -> String {
        
        var jsonString = ""
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: data,
                                                      options: JSONSerialization.WritingOptions(rawValue: 0))
            jsonString = NSString(data: jsonData,
                                  encoding: String.Encoding.utf8.rawValue)! as String
        } catch {
            print("Error converting data \(error)")
        }
        
        return jsonString
    }
    
    
    /// Retrieves the first name of the facebook user logged in
    ///
    /// - Parameter completion: Success with first name, or failure if first name could not be accessed
    static func facebookUserName(completion: @escaping FacebookNameCompletionHandler) {
        
        GraphRequest(graphPath: "me", parameters: ["fields": "first_name"], accessToken: AccessToken.current,
                     httpMethod: .GET,
                     apiVersion: .defaultVersion).start({ (_, result) in
            switch result {
            case .success(response: let response):
                if let name = response.dictionaryValue?["first_name"] as? String {
                        completion(.success(name))
                } else {
                    completion(.failure)
                }
            case .failed( _):
                    completion(.failure)
            }
        })
    }
    
    /// NSMutableDictionary that  contains all previously created NumberFormatter in stock price style
    static private var currencyNumberFormatterDictionary = NSMutableDictionary()
    
    /// Default price number formatter
    static var priceNumberFormatter: NumberFormatter {
        
        return currencyNumberFormatter(locale: "en_US",
                                       currencyCode: "",
                                       negativeFormat: "-",
                                       positiveFormat: "",
                                       currencySymbol: "")
    }
    
    /// Creates a currency number formatter based on passed params. If same formatter was already created, we will re-use that one instead of creating it again
    ///
    /// - parameter locale:         String geographic location we would like to set for the currency
    /// - parameter currencyCode:   String three letter code to denote the currency unit
    /// - parameter negativeFormat: String format that negative values will display as
    /// - parameter positiveFormat: String format that positive values will display as
    ///
    /// - returns: NumberFormatter in the approriate currency format
    static private func currencyNumberFormatter(locale:String?,
                                                currencyCode:String,
                                                negativeFormat:String,
                                                positiveFormat:String,
                                                currencySymbol:String) -> NumberFormatter {
        
        let key = String(format:"currency:%@negative:%@positive:%@", currencyCode, negativeFormat, positiveFormat)
        let currencyFormatter: NumberFormatter
        
        if let formatter = currencyNumberFormatterDictionary.object(forKey: key) as? NumberFormatter {
            // If formatter was already created then lets use it instead of creating the same one again
            currencyFormatter = formatter
        } else {
            // If the currency formatter has not been already created, create it
            let newFormatter = NumberFormatter()
            newFormatter.numberStyle = .currency
            newFormatter.currencyCode = currencyCode
            newFormatter.currencySymbol = currencySymbol
            if let locale = locale {
                newFormatter.locale = Locale(identifier: locale)
            }
            newFormatter.negativeFormat = negativeFormat.appending(newFormatter.negativeFormat)
            newFormatter.positiveFormat = positiveFormat.appending(newFormatter.positiveFormat)
            
            // Store currency formatter for future use
            currencyNumberFormatterDictionary.setValue(newFormatter, forKey: key)
            currencyFormatter = newFormatter
        }
        
        return currencyFormatter
    }

}
