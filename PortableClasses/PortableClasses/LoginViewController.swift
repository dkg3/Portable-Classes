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
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }

    @IBAction func loginAction(_ sender: Any) {
        Auth.auth().signIn(withEmail: userEmail.text!, password: userPassword.text!) { (user, error) in
            if error == nil{
                let path = Bundle.main.path(forResource: "add", ofType:"mp3")!
                let url = URL(fileURLWithPath: path)
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer.play()
                } catch {
                    
                }
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
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "loginToHome", sender: nil)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}
