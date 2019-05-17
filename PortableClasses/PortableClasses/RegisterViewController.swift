//
//  RegisterViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 4/23/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class RegisterViewController: UIViewController {

    // variables for the email and password text fields
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    // variables for the privacy features
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var privacyDescription: UITextView!
    @IBOutlet weak var pSwitch: UISwitch!
    
    // flag for a public or private account
    var publicAccount:Bool! = false
    
    // initial variable for sound
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // start with the switch in the off position
        pSwitch.setOn(false, animated: true)
        // handle a tap gesture by calling handleTap function
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    @IBAction func backToLogin(_ sender: Any) {
        // go back to the login page
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // start with the switch in the off position
        pSwitch.setOn(false, animated: true)
    }
    
    @IBAction func `switch`(_ sender: UISwitch) {
        // toggle the privacy of an account based on the switch being on or off
        if sender.isOn {
            // public
            publicAccount = true
        }
        else {
            // private
            publicAccount = false
        }
        
        // play the flip sound when toggling the switch
        let path = Bundle.main.path(forResource: "flip", ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            
        }
    }
    
    
    @IBAction func signUpAction(_ sender: Any) {
        // check if the password contains a lowercase letter
        let lowerLetterRegEx  = ".*[a-z]+.*"
        let test1 = NSPredicate(format:"SELF MATCHES %@", lowerLetterRegEx)
        let lowerresult = test1.evaluate(with: userPassword.text!)
        
        // check if the password contains an uppercase letter
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let test2 = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = test2.evaluate(with: userPassword.text!)
        
        // check if the password contains a number
        let numberRegEx  = ".*[0-9]+.*"
        let test3 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = test3.evaluate(with: userPassword.text!)
        
        // check if the password contains a special character
        let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
        let test4 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        let specialresult = test4.evaluate(with: userPassword.text!)
        
        // email must end in @nyu.edu
        if !(userEmail.text!.hasSuffix("@nyu.edu")) {
            let alertController = UIAlertController(title: "Non-NYU Email", message: "Please enter an NYU email", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        // email must be at least 11 characters to be a valid NYU email
        else if userEmail.text!.count < 11 {
            let alertController = UIAlertController(title: "NYU Email invalid", message: "The email is too short", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        // password must be at least 8 characters
        else if userPassword.text!.count < 8 {
            let alertController = UIAlertController(title: "Password Too Short", message: "Must be at least 8 characters", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        // check for a lowercase character
        else if !(lowerresult) {
            let alertController = UIAlertController(title: "Missing Lowercase", message: "Must have at least one lowercase letter", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        // check for a uppercase character
        else if !(capitalresult) {
            let alertController = UIAlertController(title: "Missing Capital", message: "Must have at least one capital letter", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        // check for a number
        else if !(numberresult) {
            let alertController = UIAlertController(title: "Missing Number", message: "Must have at least one number", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        // check for a special character
        else if !(specialresult) {
            let alertController = UIAlertController(title: "Missing Special Character", message: "Must have at least one special character", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        // email and password follow guidelines, must check for duplicates now
        else {
            Auth.auth().createUser(withEmail: userEmail.text!, password: userPassword.text!){ (user, error) in
                // can create the user
                if error == nil {
                    // get reference to firebase
                    let db = Firestore.firestore()
                    // add user to db
                    var ref: DocumentReference? = nil
                    // get reference to the current user by their email
                    ref = db.collection("users").document(self.userEmail.text!)
                    // set their email, privacy setting, and default location in the database
                    ref?.setData([
                        "email": self.userEmail.text!,
                        "public": self.publicAccount,
                        "location": GeoPoint(latitude: 0, longitude: 0)
                    ]) { err in
                        if err != nil {}
                    }
                    // create semesters array
                    let semestersRef = ref?.collection("semesters")
                    let semestersCollectionRef = semestersRef?.document("semesters")
                    // have an empty array to start
                    semestersCollectionRef?.setData([
                        "semesters": []
                    ]) { err in
                        if err != nil {}
                    }
                    
                    // play the success sound since the user is successfully created
                    let path = Bundle.main.path(forResource: "add", ofType:"mp3")!
                    let url = URL(fileURLWithPath: path)
                    do {
                        self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                        self.audioPlayer.play()
                    } catch {
                        
                    }
                    // log the user in and go to the overview page
                    self.performSegue(withIdentifier: "signupToHome", sender: self)
                }
                // can't create the user, probably because duplicate email
                else {
                    // display an error message to the user
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // dismiss the keyboard when the screen is tapped
        view.endEditing(true)
    }
    
}
