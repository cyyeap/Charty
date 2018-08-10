//
//  WelcomeController.swift
//  ARChartsSampleApp
//
//  Created by Arend Oppewal on 9/8/18.
//  Copyright © 2018 Boris Emorine. All rights reserved.
//

import UIKit
import LocalAuthentication

class WelcomeController: UIViewController
{
    var context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapStartButton(_ sender: UIButton) {
        handleLogin()
        return
        
        context = LAContext()
        context.localizedFallbackTitle = "Use passcode?"
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            self.loginWithSystem()
        } else {
            print(error?.localizedDescription ?? "Can't evaluate policy - Biometrics not available?")
            //self.performSegue(withIdentifier: "WelcomeSegue", sender: nil)
            self.loginWithAppPasscode()
        }
    }
    
    private func loginWithSystem() {
        let reason = "Log in to your account"
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { (success, error) in
            if success {
                self.handleLogin()
            } else {
                print(error?.localizedDescription ?? "Failed to authenticate")
                if let err = error {
                    switch err._code {
                    case LAError.Code.userFallback.rawValue:
                        print("Failed to Authenticate - User Fallback")
                        self.loginWithAppPasscode()
                    case LAError.Code.userCancel.rawValue:
                        print("Failed to Authenticate - User Cancelled")
                    case LAError.Code.systemCancel.rawValue:
                        print("Failed to Authenticate - Cancelled by app")
                    default:
                        print("Failed to Authenticate - Unknown Reason")
                    }
                }
            }
        }
    }
    
    private func loginWithAppPasscode() {
        let reason = "Log in to your account"
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { (success, error) in
            if success {
                self.handleLogin()
            }
        }
    }
    
    private func handleLogin() {
        DispatchQueue.main.async { [unowned self] in
            self.performSegue(withIdentifier: "WelcomeSegue", sender: nil)
        }
    }
}
