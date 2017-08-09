//
//  UserWatchlistCell.swift
//  StockTestApp
//
//  Created by Brett M Johnsen on 8/7/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import Foundation
import UIKit

protocol UserWatchlistCellDelegate: class {
    
    /// Delete was pressed in cell
    ///
    /// - Parameter watchlistName: String of the name of the watchlist that is to be deleted
    func deletePressed(watchlistName: String)
    
    /// Name of watchlist was edited
    ///
    /// - Parameters:
    ///   - oldName: String of the old name of watchlist before edited
    ///   - newName: String of new name of watchlist after being edited
    func nameEdited(fromName oldName: String, toName newName: String?)
}

/// Custom cell of editing and viewing the user's watchlists
final class UserWatchlistCell: UITableViewCell {
    
    weak var delegate: UserWatchlistCellDelegate?
    var isDuplicateList = false
    
    @IBOutlet var name: UILabel!
    @IBOutlet var nameEditMode: UITextField!
    @IBOutlet var editView: UIView!
    
    // Update edit mode, if hidden then show. If shown then hide
    func updateEditMode() {
        
        editView.isHidden = !editView.isHidden
        nameEditMode.becomeFirstResponder()
    }
    
    @IBAction func didPressEdit(_ sender: UIButton) {
        
        updateEditMode()
    }
    
    @IBAction func didPressDelete(_ sender: UIButton) {
        
        if let name = name.text {
            AlertHandler.showAlert(withTitle: "",
                                   message: "Are you sure you want to remove this symbol from watchlist:\n\(AppSession.currentWatchlistName)") { [weak self] in
                                    self?.delegate?.deletePressed(watchlistName: name)
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate

extension UserWatchlistCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // Workaround for iOS 9 bug where text jumps on editing
        textField.layoutIfNeeded()
        
        // replace old watchlist with new watchlist if name was changed
        if !isDuplicateList,
            let currentName = name.text,
            let editName = nameEditMode.text,
            let currentWatchlist = AppSession.userWatchlists[currentName] {
            
            // update watchlist data
            var updatedWatchlist = currentWatchlist
            updatedWatchlist.name = editName
            AppSession.userWatchlists.removeValue(forKey: currentName)
            AppSession.userWatchlists[editName] = updatedWatchlist
            
            // update watchlist text
            name.text = editName
            
            // inform delegate if set
            delegate?.nameEdited(fromName: currentName,
                                 toName: editName)
            editView.isHidden = true
        } else {
            isDuplicateList = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        var isReturning = true
        if let currentName = name.text,
            let editName = nameEditMode.text,
            currentName != editName {
            
            for userWatchlist in AppSession.orderedWatchlist {
                // we do not allow lists with the same name to be entered
                if userWatchlist.name == editName {
                    isReturning = false
                    isDuplicateList = true
                    AlertHandler.showSimpleAlert(withTitle: "Duplicate List",
                                                 message: "Please enter a name that does not already exist. ")
                    break
                }
            }
        }
        
        if isReturning {
            textField.resignFirstResponder()
        }
        return isReturning
    }
}
