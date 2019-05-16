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
    
    var userEmail:String?
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let db = Firestore.firestore()
//        loggedInUserEmail = (Auth.auth().currentUser?.email)!
        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
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
            
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "overviewToSemesters" {
//            let nav = segue.destination as! UINavigationController
//            let semestersVC = nav.topViewController as! SemestersTableViewController
            let semestersVC = segue.destination as! SemestersTableViewController
            semestersVC.userEmail = Auth.auth().currentUser?.email
        }
        else if segue.identifier == "overviewToMap" {
            let nav = segue.destination as! UINavigationController
            let mapVC = nav.topViewController as! MapViewController
            mapVC.userEmail = Auth.auth().currentUser?.email
        }
        
    }
}
