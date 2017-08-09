//
//  ViewController.swift
//  Stock Test App
//
//  Created by Brett M Johnsen on 8/3/17.
//  Copyright © 2017 Brett M Johnsen. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class LoginViewController: UIViewController {
    
    @IBOutlet var loginPrompt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add login button to view
        addLoginButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Add the login button to the view
    private func addLoginButton() {
        
        let loginEntry = LoginButton(readPermissions: [.publicProfile])
        loginEntry.delegate = self
        loginEntry.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginEntry)
        
        // Configure Constraints
        let loginTop = loginEntry.topAnchor.constraint(equalTo: loginPrompt.bottomAnchor)
        loginTop.constant = 15
        loginTop.isActive = true
        loginEntry.centerXAnchor.constraint(equalTo: loginPrompt.centerXAnchor).isActive = true
    }
    
}

extension LoginViewController: LoginButtonDelegate {
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        
        switch result {
        case .success(grantedPermissions: _, declinedPermissions: _, token: let token):
            print(token.authenticationToken)
            print(token.userId)
            
        case .failed(let error):
            print(error.localizedDescription)
        case .cancelled:
            print("canceled")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("logout")
    }
}

