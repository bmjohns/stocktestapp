//
//  TKeychainManager.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/3/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation

/**
 Error types to be returned while querying keychain

 - accessControlError:     will be returned incase if access control is not created
 - noData:             will returned if there is no matching data found
 - unexpectedData: will be returned if data is stored
 - unhandledError:         will be reurned in case any unhandled error woth OSStatus code
 */
public enum TNTKeychainError: Error {

    case accessControlError
    case noData
    case unexpectedData
    case unexpectedItemData
    case userCanceled
    case unhandledError(status: OSStatus)
}

public struct TNTKeychainManager {

    fileprivate static let accessGroup: String? = nil

    // MARK: Read Keychain

    /**
     Method to read value from keystore

     - parameter account: account string for which data to be read
     - parameter service: service string under which data to be read

     - throws: TNTKeychainError in case of any exception

     - returns: the stored data for the account and service
     */
    public static func readDataFromKeychain(_ account: String, service: String) throws -> String {

        /*
         Build a query to find the item that matches the service, account and
         access group.
         */

        let query = TNTKeychainManager.queryForKeychain(account,
            service: service)
        return try TNTKeychainManager.queryKeychainForData(query)
    }

    /**
     Method to form base query for reading data from keychain

     - parameter account: account for which query to be made
     - parameter service: service for which query to be made

     - returns: base query as dict [String: AnyObject]
     */
    fileprivate static func queryForKeychain(_ account: String, service: String) -> [String: AnyObject] {

        var query = TNTKeychainManager.keychainQuery(withService: service,
            account: account,
            accessGroup: TNTKeychainManager.accessGroup)

        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        return query
    }

    /**
     Method to fech data from keychain based on the query parameters

     - parameter query: Query for which data to be read from keychain

     - throws: TNTKeychainError in case of any exception

     - returns: string data for the query
     */
    fileprivate static func queryKeychainForData(_ query: [String: AnyObject]) throws -> String {

        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {

            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw TNTKeychainError.noData }
        guard status != errSecUserCanceled else { throw TNTKeychainError.userCanceled }
        guard status == noErr else { throw TNTKeychainError.unhandledError(status: status) }

        // Parse the data string from the query result.
        guard let existingItem = queryResult as? [String: AnyObject],
            let data = existingItem[kSecValueData as String] as? Data,
            let dataString = String(data: data, encoding: String.Encoding.utf8)
        else {

            throw TNTKeychainError.unexpectedData
        }

        return dataString
    }

    // MARK: Save Keychain

    /**
     Method to save data in keychain

     - parameter data: data string to be stored in keychain
     - parameter account:  account string for which data to be stored
     - parameter service:  service string under which data to be stored

     - throws: TNTKeychainError in case of any exception
     */
    public static func saveDataInKeychain(_ data: String, account: String, service: String) throws {

        // Encode the data into an Data object.
        let encodedData = data.data(using: String.Encoding.utf8)
        var newItem = TNTKeychainManager.keychainQuery(withService: service,
            account: account,
            accessGroup: accessGroup)
        newItem[kSecValueData as String] = encodedData as AnyObject?
        // Add a the new item to the keychain.
        let status = SecItemAdd(newItem as CFDictionary, nil)

        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw TNTKeychainError.unhandledError(status: status) }
    }

    // MARK: Update Keychain

    /**
     Method to update data in keychain

     - parameter data: new data string to be updated in keychain for the account
     - parameter account: account string for which data to be updated
     - parameter service: account string for which data to be updated

     - throws: TNTKeychainError in case of any exception
     */
    public static func updateDataInKeychain(_ data: String, account: String, service: String) throws {

        // Encode the data into an Data object.
        let encodeddata = data.data(using: String.Encoding.utf8)
        var attributesToUpdate = [String: Data]()
        attributesToUpdate[kSecValueData as String] = encodeddata
        let query = TNTKeychainManager.keychainQuery(withService: service,
            account: account,
            accessGroup: accessGroup)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw TNTKeychainError.unhandledError(status: status) }

    }

    // MARK: Delete Keychain

    /**
     Method to delete keychain item for the account

     - parameter account: account string for which data to be deleted
     - parameter service: service string for which data to be deleted

     - throws: TNTKeychainError in case of any exception
     */
    public static func deleteItem(_ account: String?, service: String) throws {

        // Delete the existing item from the keychain.
        let query = TNTKeychainManager.keychainQuery(withService: service,
            account: account,
            accessGroup: TNTKeychainManager.accessGroup)
        let status = SecItemDelete(query as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw TNTKeychainError.unhandledError(status: status) }
    }

    // MARK: Convenience

    /**
     Method to form keychain query for read/save/update and delete data from keychain

     - parameter service:     service name to form keychain query
     - parameter account:     account name to form keychain query
     - parameter accessGroup: access group for shaing keychain data

     - returns: Query dictionary object for querying keychain
     */
    fileprivate static func keychainQuery(withService service: String,
        account: String? = nil,
        accessGroup: String? = nil) -> [String: AnyObject] {

            var query = [String: AnyObject]()
            query[kSecClass as String] = kSecClassGenericPassword
            query[kSecAttrService as String] = service as AnyObject?

            if let account = account {

                query[kSecAttrAccount as String] = account as AnyObject?
            }

            if let accessGroup = accessGroup {

                query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
            }

            return query
    }
    
}
