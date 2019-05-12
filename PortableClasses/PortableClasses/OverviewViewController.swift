//
//  OverviewViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 5/2/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class OverviewViewController: UIViewController {
    
    @IBOutlet weak var welcomeUser: UILabel!
    @IBOutlet weak var pSwitch: UISwitch!
    
    var publicAccount:Bool!
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let db = Firestore.firestore()
        
        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        
        userRef!.getDocument { (document, error) in
            if error != nil {
                print("Could not find document")
            }
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                   
                    DispatchQueue.main.async {
                        self.pSwitch.setOn(data["public"]! as! Bool, animated: true)
                        self.welcomeUser.text = "Welcome, " +  (data["email"]! as! String)
                    }
                })
            })
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    @IBAction func `switch`(_ sender: UISwitch) {
        let db = Firestore.firestore()
        
        var userRef: DocumentReference? = nil
        
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        
        
        if sender.isOn {
            publicAccount = true
        }
        else {
            publicAccount = false
        }
        
        userRef?.updateData([
            "public": self.publicAccount
            ])
        
        let path = Bundle.main.path(forResource: "flip", ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            print("uh oh")
        }
        
        print(self.publicAccount)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}
