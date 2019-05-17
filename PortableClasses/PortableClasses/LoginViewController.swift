//
//  LoginViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 4/23/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class LoginViewController: UIViewController {
    
    // variables for the email and password text fields
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    // initial variable for sound
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // handle a tap gesture by calling handleTap function
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }

    // when login button is clicked
    @IBAction func loginAction(_ sender: Any) {
        // use firebase authentication to attempt to sign in user
        Auth.auth().signIn(withEmail: userEmail.text!, password: userPassword.text!) { (user, error) in
            // if the email and password match a user
            if error == nil{
                // play the success sound
                let path = Bundle.main.path(forResource: "add", ofType:"mp3")!
                let url = URL(fileURLWithPath: path)
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer.play()
                } catch {
                    
                }
                // log the user in and go to the overview page
                self.performSegue(withIdentifier: "loginToHome", sender: self)
            }
            // email and password don't match a user
            else {
                // present an error message of why the user couldn't log in
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        // if the user previously signed in, send them directly to the overview page
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "loginToHome", sender: nil)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // dismiss the keyboard when the screen is tapped
        view.endEditing(true)
    }
    
}
