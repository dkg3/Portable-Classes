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

    let email = "slg@nyu.edu";
    let password = "Abcd@!12";
    
    @IBAction func signUpAction(_ sender: Any) {
        let lowerLetterRegEx  = ".*[a-z]+.*"
        let test1 = NSPredicate(format:"SELF MATCHES %@", lowerLetterRegEx)
        let lowerresult = test1.evaluate(with: password)
        
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let test2 = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = test2.evaluate(with: password)
        
        let numberRegEx  = ".*[0-9]+.*"
        let test3 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = test3.evaluate(with: password)
        
        let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
        let test4 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        let specialresult = test4.evaluate(with: password)
        
        
        if !(email.hasSuffix("@nyu.edu")) {
            let alertController = UIAlertController(title: "Non-NYU Email", message: "Please enter an NYU email", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else if email.count < 11 {
            let alertController = UIAlertController(title: "NYU Email invalid", message: "The email is too short", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else if password.count < 8 {
            let alertController = UIAlertController(title: "Password Too Short", message: "Must be at least 8 characters", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else if !(lowerresult) {
            let alertController = UIAlertController(title: "Missing Lowercase", message: "Must have at least one lowercase letter", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else if !(capitalresult) {
            let alertController = UIAlertController(title: "Missing Capital", message: "Must have at least one capital letter", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else if !(numberresult) {
            let alertController = UIAlertController(title: "Missing Number", message: "Must have at least one number", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else if !(specialresult) {
            let alertController = UIAlertController(title: "Missing Special Character", message: "Must have at least one special character", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            Auth.auth().createUser(withEmail: email, password: password){ (user, error) in
                if error == nil {
                    self.performSegue(withIdentifier: "signupToHome", sender: self)
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
}
