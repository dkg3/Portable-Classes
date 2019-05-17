//
//  NotesViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/3/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class NotesViewController: UITableViewController {

    // array of user's notes
    var notes = [String]()
    // the current semester and class selected
    var currSemester = ""
    var currClass = ""
    // user from map table, not the logged in user
    var userEmail:String!
    // index of the note selected
    var index = 0
    
    // initial variable for sound
    var audioPlayer = AVAudioPlayer()
    
    // get access to firebase
    let db = Firestore.firestore()
    var userRef: DocumentReference? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // reference to the user selected
        userRef = db.collection("users").document(userEmail!)
        // reference to the document of notes
        let notesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("notes")
        // display the notes in the view controller
        notesRef!.getDocument { (document, error) in
            if error != nil {}
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload table once db returns array of notes
                    DispatchQueue.main.async {
                        self.notes = data["notes"]! as! [String]
                        self.tableView.reloadData()
                    }
                })
            })
        }
        // only allow user to edit their own content
        if userEmail == (Auth.auth().currentUser?.email)! {
            // display an Edit button in the navigation bar for this view controller
            self.navigationItem.rightBarButtonItem = self.editButtonItem
            let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
            navigationItem.rightBarButtonItems?.append(add)
        }
        
    }
    
    @objc func addTapped() {
        // go to the add note view
        performSegue(withIdentifier: "notesToAdd", sender: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // configure the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        let note = notes[indexPath.row]
        // set the text field and style the text
        cell.textLabel?.text = note
        cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // only allow editing if current user displayed is logged in user
        return userEmail == (Auth.auth().currentUser?.email)!
    }
    
    // editing the table view
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // reference to the current user
            userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
            // reference to the document of notes
            let notesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("notes")
            // remove the selected notes from the database
            notesRef?.updateData([
                "notes": FieldValue.arrayRemove([notes[indexPath.row]])
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                }
            }
            // remove the selected note from the table view
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // play the delete sound when removing a row
            let path = Bundle.main.path(forResource: "delete", ofType:"wav")!
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
            } catch {
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // callback from add note
        if let addNotesVC = segue.destination as? AddNoteViewController {
            addNotesVC.callback = { message in
                // if the note doesn't already exist
                if !self.notes.contains(message) {
                    // reference to the current user
                    self.userRef = self.db.collection("users").document((Auth.auth().currentUser?.email)!)
                    // reference to the document of notes
                    let notesRef = self.userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("notes")
                    // add the new note
                    notesRef?.updateData([
                        "notes": FieldValue.arrayUnion([message])
                        ])
                    // add the new note to the array of notes
                    self.notes.append(message)
                    return true
                }
                else {
                    // alert user note already exists
                    let alert = UIAlertController(title: "This note already exists", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) { (_) in
                        return
                    }
                    // display the alert
                    alert.addAction(okAction)
                    addNotesVC.present(alert, animated: true)
                    return false
                }
            }
        }
        // callback from view note
        else if let editNotesVC = segue.destination as? ViewNoteViewController {
            editNotesVC.callback = { message in
                // update the note in the array of notes
                self.notes[self.index] = message
                // reference to the current user
                self.userRef = self.db.collection("users").document((Auth.auth().currentUser?.email)!)
                // reference to the document of notes
                let notesRef = self.userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("notes")
                // update the existing note
                notesRef?.updateData([
                    "notes": self.notes
                    ])
            }
        }
        // segue to the completed note view
        if segue.identifier == "notesToCompleted" {
            // pass the current note text, the index of the note, the user's email
            let viewNoteVC = segue.destination as! ViewNoteViewController
            viewNoteVC.currNote = self.notes[tableView.indexPathForSelectedRow!.row]
            index = tableView.indexPathForSelectedRow!.row
            viewNoteVC.userEmail = userEmail
        }
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // reload the table when the view appears to make sure data is updated
        self.tableView.reloadData()
    }

}
