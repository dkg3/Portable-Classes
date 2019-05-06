//
//  NotesViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/3/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class NotesViewController: UITableViewController {

    var notes = [String]()
    
    var currSemester = ""
    var currClass = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        
        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        let notesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("notes")
        
        notesRef!.getDocument { (document, error) in
            if error != nil {
                print("Could not find document")
            }
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload table once db returns array of semesters
                    DispatchQueue.main.async {
                        self.notes = data["notes"]! as! [String]
                        self.tableView.reloadData()
                    }
                })
            })
        }
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        navigationItem.rightBarButtonItems?.append(add)
        
    }
    @objc func addTapped() {
        performSegue(withIdentifier: "notesToAdd", sender: self)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        
        // Configure the cell...
        
        let note = notes[indexPath.row]
        cell.textLabel?.text = note
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let db = Firestore.firestore()
            
            var userRef: DocumentReference? = nil
            userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
            
            let notesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("notes")
            
            notesRef?.updateData([
                "notes": FieldValue.arrayRemove([notes[indexPath.row]])
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            
            
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addNotesVC = segue.destination as? AddNoteViewController {
            addNotesVC.callback = { message in
                let db = Firestore.firestore()
                var userRef: DocumentReference? = nil
                userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
                let notesRef = userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("notes")
                notesRef?.updateData([
                    "notes": FieldValue.arrayUnion([message])
                    ])
                self.notes.append(message)
            }
        }
        if segue.identifier == "notesToCompleted" {
            let viewNoteVC = segue.destination as! ViewNoteViewController
            viewNoteVC.currNote = self.notes[tableView.indexPathForSelectedRow!.row]
        }
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

}
