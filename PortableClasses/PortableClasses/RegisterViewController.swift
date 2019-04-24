//
//  RegisterViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 4/23/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad();
    }

    let email = "ar4477@nyu.edu";
    let password = "abc123easy";
    let passwordConfirm = "abc123easy";
    
    @IBAction func signUpAction(_ sender: Any) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                //something bad happning
                print(error!.localizedDescription )
            }
            else {
                //user registered successfully
                print(self.password)
            }
        }
//        if password.text != passwordConfirm.text {
//            let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
//            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alertController.addAction(defaultAction)
//            self.present(alertController, animated: true, completion: nil)
//
//        }
//        else {
//            Auth.auth().createUser(withEmail: email.text!, password: password.text!){ (user, error) in
//                if error == nil {
//                    self.performSegue(withIdentifier: "signupToHome", sender: self)
//
//                }
//                else {
//                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
//                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                    alertController.addAction(defaultAction)
//                    self.present(alertController, animated: true, completion: nil)
//
//                }
//            }
//        }
    }
}
