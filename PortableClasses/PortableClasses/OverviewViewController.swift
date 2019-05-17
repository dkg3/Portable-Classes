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
    
    // variables referencing the welcome string and the privacy switch
    @IBOutlet weak var welcomeUser: UILabel!
    @IBOutlet weak var pSwitch: UISwitch!
    
    // privacy flag
    var publicAccount:Bool!
    
    // user's email
    var userEmail:String?
    
    // initial variable for sound
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // hide the nav bar in this view
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // get access to firebase
        let db = Firestore.firestore()
        var userRef: DocumentReference? = nil
        // reference to the current user
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        // display the switch in the on or off setting based on the user's settings
        // and show a welcome text with the user's email
        userRef!.getDocument { (document, error) in
            if error != nil {}
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
        // hide the nav bar in this view
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func `switch`(_ sender: UISwitch) {
        // get access to firebase
        let db = Firestore.firestore()
        var userRef: DocumentReference? = nil
        // reference to the current user
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        // flag set to public account
        if sender.isOn {
            publicAccount = true
        }
        // flag set to private account
        else {
            publicAccount = false
        }
        // update the field when the switch is toggled
        userRef?.updateData([
            "public": self.publicAccount
            ])
        
        // play the flip sound when toggling the switch
        let path = Bundle.main.path(forResource: "flip", ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        // logout the user when clicking the sign out button
        do {
            try Auth.auth().signOut()
        }
        // print an error message if this can't be done for any reason
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // go to the semesters view
        if segue.identifier == "overviewToSemesters" {
            // pass the user's email to the new view controller
            let semestersVC = segue.destination as! SemestersTableViewController
            semestersVC.userEmail = Auth.auth().currentUser?.email
        }
        // go to the map view
        else if segue.identifier == "overviewToMap" {
            // pass the user's email to the new view controller
            let nav = segue.destination as! UINavigationController
            let mapVC = nav.topViewController as! MapViewController
            mapVC.userEmail = Auth.auth().currentUser?.email
        }
        
    }
}
