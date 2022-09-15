//
//  LoginViewController.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import UIKit

class LoginViewController: UIViewController {
  
  // IBOutlets
  @IBOutlet private weak var label: UILabel!
  @IBOutlet private weak var button: UIButton!
  
  
  // IBActions
  @IBAction private func onLogin(_ sender: UIButton) {
    authenticate()
  }
  
  // MARK: Properties
  
  // MARK: Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // UI modifications
    button.alpha = 0
    button.layer.cornerRadius = 9.0
    button.clipsToBounds = true
    
    view.layoutIfNeeded()
    
    // User.instance.logout()
    
    User.instance.notifyWhenReady = { [weak self] in
      guard let self = self else { return }
      if User.instance.isAuthenticated {
        self.performSegue(withIdentifier: "ToWelcome", sender: nil)
      } else {
        self.label.text = "You need to Log In to use the Pokedex app!"
        self.button.alpha = 1
      }
    }
  }
  
  private func authenticate() {
    self.label.text = "Logging you in... Please wait."
    self.button.alpha = 0
    self.view.layoutIfNeeded()
    
    User.instance.authenticate() { [weak self] success in
      guard let self = self else { return }
      if !success {
        self.label.text = "Oops! Something bad happened. Please try it again!"
        self.button.alpha = 1
        self.view.layoutIfNeeded()
      }
    }
  }
}
