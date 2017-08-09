//
//  TNTKeychainHelper.swift
//  Wealth Passport Mobile
//
//  Created by Kumaravel Deivasigamani on 7/18/16.
//  Copyright © 2016 Northern Trust. All rights reserved.
//

import Foundation

/**
 *  Helper class to get data from keychain
 */
struct TNTKeychainHelper {

    // MARK: Keychain

    /**
     Method to get data from keychain for the account

     - parameter account: account name string

     - returns: data if matching foung else return empty string
     */
    static func getData(_ account: String) -> String {

        var dataStr: String = ""
        do {

            dataStr = try TNTKeychainManager.readDataFromKeychain(account,
                service: AppConstants.serviceName)
        } catch {

            print("Error reading data from keychain - \(error)")
        }
        return dataStr
    }

    /**
     Method to save data to keychain

     - parameter data:    string to be saved in keychain
     - parameter account: account name string
     */
    static func saveData(_ data: String, account: String) {

        do {
            deleteData(account)
            
            try TNTKeychainManager.saveDataInKeychain(data,
                account: account,
                service: AppConstants.serviceName)
        } catch {

            print("Error saving data \(error)")
        }
    }

    /**
     Method to delete data from keychain

     - parameter account: account name string
     */
    static func deleteData(_ account: String) {

        do {

            try TNTKeychainManager.deleteItem(account,
                service: AppConstants.serviceName)
        } catch {

            print("Error deleting data from keychain - \(error)")
        }
    }

    /**
     Method to clear all keychain data during fresh Install
     */
    static func clearKeychainEntriesForFirstTimeInstall() {

        TNTKeychainHelper.deleteData(AppConstants.keychainSaveIDUsername)
        TNTKeychainHelper.deleteData(AppConstants.keychainLastLoggedInUsername)
        TNTTouchIDHandler.deleteAllTouchIDUsers()
    }

}
