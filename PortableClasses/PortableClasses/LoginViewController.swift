//
//  LoginViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 4/23/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    let email = "mll503@nyu.edu";
    let password = "Abcd@!12";

    @IBAction func loginAction(_ sender: Any) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil{
                self.performSegue(withIdentifier: "loginToHome", sender: self)
            }
            else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
