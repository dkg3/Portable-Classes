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

    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var privacyDescription: UITextView!
    @IBOutlet weak var pSwitch: UISwitch!
    
    var publicAccount:Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad();
        pSwitch.setOn(false, animated: true)
        print(pSwitch.isOn)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        pSwitch.setOn(false, animated: true)
        print(pSwitch.isOn)
    }
    
    @IBAction func `switch`(_ sender: UISwitch) {
        if sender.isOn {
//            privacyLabel.text = "Public Account"
//            privacyDescription.text = "Allow other users to see you on the map."
            publicAccount = true
            
        }
        else {
//            privacyLabel.text = "Private Account"
//            privacyDescription.text = "Other users will not be able to see you on the map"
            publicAccount = false
        }
    }
    
    
    @IBAction func signUpAction(_ sender: Any) {
        let lowerLetterRegEx  = ".*[a-z]+.*"
        let test1 = NSPredicate(format:"SELF MATCHES %@", lowerLetterRegEx)
        let lowerresult = test1.evaluate(with: userPassword.text!)
        
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let test2 = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = test2.evaluate(with: userPassword.text!)
        
        let numberRegEx  = ".*[0-9]+.*"
        let test3 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = test3.evaluate(with: userPassword.text!)
        
        let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
        let test4 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        let specialresult = test4.evaluate(with: userPassword.text!)
        
        
        if !(userEmail.text!.hasSuffix("@nyu.edu")) {
            let alertController = UIAlertController(title: "Non-NYU Email", message: "Please enter an NYU email", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else if userEmail.text!.count < 11 {
            let alertController = UIAlertController(title: "NYU Email invalid", message: "The email is too short", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else if userPassword.text!.count < 8 {
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
            
            
            
            
            
            Auth.auth().createUser(withEmail: userEmail.text!, password: userPassword.text!){ (user, error) in
                if error == nil {
                    
                    let db = Firestore.firestore()
                    // add user to db
                    var ref: DocumentReference? = nil
                    ref = db.collection("users").document(self.userEmail.text!)
                    ref?.setData([
                        "email": self.userEmail.text!,
                        "public": self.publicAccount,
                        "location": GeoPoint(latitude: 0, longitude: 0)
                    ]) { err in
                        if err != nil {
                            print("Error adding document")
                        }
                    }
                    // create semesters array
                    let semestersRef = ref?.collection("semesters")
                    let semestersCollectionRef = semestersRef?.document("semesters")
                    semestersCollectionRef?.setData([
                        "semesters": []
                    ]) { err in
                        if err != nil {
                            print("Error adding collection")
                        }
                    }
                    
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
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
