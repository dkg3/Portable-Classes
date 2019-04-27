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
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var semesters = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        tableView.rowHeight = 90
        
        let db = Firestore.firestore()
        
        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        
        let semestsRef = userRef?.collection("semesters").document("semesters")
        semestsRef!.getDocument { (document, error) in
            if error != nil {
                print("Could not find document")
            }
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload table once db returns array of semesters
                    DispatchQueue.main.async {
                        self.semesters = data["semesters"]! as! [String]
                        self.tableView.reloadData()
                    }
                })
            })
        }
    }
    
    @IBAction func onAddTapped() {
        let alert = UIAlertController(title: "Add Semester", message: nil, preferredStyle: .alert)
        alert.addTextField {(semesterTF) in
            semesterTF.placeholder = "Enter Semester"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let semester = alert.textFields?.first?.text else {return}
            self.add(semester)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (_) in
            return
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true)
    }
    
    func add(_ semester: String) {
        
        let db = Firestore.firestore()
        
        var userRef: DocumentReference? = nil
        
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        let semestsRef = userRef?.collection("semesters").document("semesters")
        
        // append semester
        semestsRef?.updateData([
            "semesters": FieldValue.arrayUnion([semester])
        ]) { err in
            if err != nil {
                print("Error adding document")
            } else {
                // initialize classes array for this semester
                let classesRef = semestsRef?.collection("classes")
                let classesDoc = classesRef?.document("classes")
                classesDoc?.setData([
                    "classes": []
                ]) { err in
                    if err != nil {
                        print("Error adding document")
                    } else {
                        // add semester to table
                        let index = 0
                        self.semesters.insert(semester, at: index)
                        let indexPath = IndexPath(row: index, section: 0)
                        self.tableView.insertRows(at: [indexPath], with: .left)
                    }
                }
            }
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
    
}

extension SemestersViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return semesters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        cell.backgroundColor = UIColor(cgColor: (tableView.backgroundColor?.cgColor)!)
        
        let semester = semesters[indexPath.row]
        cell.textLabel?.text = semester
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        semesters.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
}
