//
//  SemesterViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 4/24/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class SemestersViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func addSemesterPopUp(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add Semester", message: "Please type your semester.", preferredStyle: .alert)
    
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // TODO: look at other styles
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            let semesterName = textField?.text
            self.addSemesterToTable(semester: semesterName!)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func addSemesterToTable(semester: String) {
        
    }
}
