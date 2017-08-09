//
//  KeychainHelper.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/3/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation

///  Helper class to get data from keychain
struct KeychainHelper {
    
    static let keychainUserIdentifier = "userID"
    static let keychainWatchlistIdentifier = "watchlist"


    // MARK: Keychain
    
    ///   Method to get data from keychain for the user
    ///
    /// - Parameter user: String of user name
    /// - Returns:  a collection of strings of the user's data
    static func getData(fromUser user: String) -> [String: String] {

        var data = [String: String]()
        do {

            let dataString = try TNTKeychainManager.readDataFromKeychain(user,
                service: AppConstants.serviceName)
            
            if let convertedData = dataString.convertToCollection() {
                data = convertedData
            }
        } catch {

            print("Error reading data from keychain - \(error)")
        }
        return data
    }
    
    ///  Method to save data to keychain
    ///
    /// - Parameters:
    ///   - data: string to be saved in keychain
    ///   - user: user name string
    static func save(data: [String: String], forUser user: String) {
        
        let jsonString = AppUtility.convertDataToString(data: data)
        
        do {
            deleteData(fromUser: user)
            
            try TNTKeychainManager.saveDataInKeychain(jsonString,
                account: user,
                service: AppConstants.serviceName)
        } catch {

            print("Error saving data \(error)")
        }
    }
    
    ///  Method to delete data from keychain
    ///
    /// - Parameter account: String of user's data we should delete
    static func deleteData(fromUser user: String) {

        do {

            try TNTKeychainManager.deleteItem(user,
                service: AppConstants.serviceName)
        } catch {

            print("Error deleting data from keychain - \(error)")
        }
    }

}
