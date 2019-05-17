//
//  ClassesTableViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 4/27/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class ClassesTableViewController: UITableViewController {
    
    // array of the classes to display
    var classes = [String]()
    // the current semester and course selected
    var currSemester = ""
    var currClass = ""
    // user from map table, not the logged in user
    var userEmail: String!
    
    // pop up variable used to display an alert to add a new course
    var addAction: UIAlertAction!
    
    // initial variable for sound
    var audioPlayer = AVAudioPlayer()
    
    // get access to firebase
    let db = Firestore.firestore()
    var userRef: DocumentReference? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // reference to the user selected
        userRef = db.collection("users").document(userEmail!)
        // reference to the document of classes
        let classesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes")
        // display the classes in the view controller
        classesRef!.getDocument { (document, error) in
            if error != nil {}
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload table once db returns array of classes
                    DispatchQueue.main.async {
                        self.classes = data["classes"]! as! [String]
                        self.tableView.reloadData()
                    }
                })
            })
        }
        
        // only allow user to edit their own content
        if userEmail == (Auth.auth().currentUser?.email)! {
            // display an Edit button in the navigation bar for this view controller.
            self.navigationItem.rightBarButtonItem = self.editButtonItem
            let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
            navigationItem.rightBarButtonItems?.append(add)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // deselect the tapped row so the gray color disappears
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    @objc func addButtonTapped(_ sender: Any) {
        // alert with a text field to add a new course
        let alert = UIAlertController(title: "Add Course", message: nil, preferredStyle: .alert)
        self.addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let course = alert.textFields?.first?.text else {return}
            self.add(course)
        }
        // selecting cancel will dismiss the alert without adding anything
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (_) in
            return
        }
        alert.addTextField {(courseTF) in
            courseTF.placeholder = "Enter Course Name"
            // add event listener to text field to toggle add button
            courseTF.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: .editingChanged)
        }
        // don't allow add capabilities until text is added
        addAction.isEnabled = false
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true)
    }
    
    // enable add button on UIActionController when there is text
    @objc func textFieldChanged(_ textField: UITextField) {
        addAction.isEnabled = textField.text!.count > 0
    }
    
    func add(_ course: String) {
        // only add course if not in the user's classes array
        if !self.classes.contains(course) {
            // reference to the current user
            userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
            // reference to the document of classes
            let classesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes")
            // append course
            classesRef?.updateData([
                "classes": FieldValue.arrayUnion([course])
            ]) { err in
                if err != nil {}
                else {
                    // initialize notes, handNotes, deadlines, & flashcards arrays for this course
                    let currClassRef = classesRef?.collection(course)
                    let notesDoc = currClassRef?.document("notes")
                    let handNotesDoc = currClassRef?.document("handNotes")
                    let deadlinesDoc = currClassRef?.document("deadlines")
                    let flashcardsDoc = currClassRef?.document("flashcards")
                    // initialize notes array
                    notesDoc?.setData([
                        "notes": [],
                    ]) { err in
                        if err != nil {}
                    }
                    // initialize hand notes array
                    handNotesDoc?.setData([
                        "handNotes": [],
                        ]) { err in
                            if err != nil {}
                    }
                    // initialize deadlines array
                    deadlinesDoc?.setData([
                        "dates": [],
                        "deadlines": [],
                        ]) { err in
                            if err != nil {}
                    }
                    // initialize notes array
                    flashcardsDoc?.setData([
                        "flashcards": [],
                        ]) { err in
                            if err != nil {}
                    }
                    
                    // add the new course to the end of the table
                    let index = self.classes.count
                    self.classes.insert(course, at: index)
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .left)
                    
                    // play the add sound when the course is successfully added
                    let path = Bundle.main.path(forResource: "add", ofType:"mp3")!
                    let url = URL(fileURLWithPath: path)
                    do {
                        self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                        self.audioPlayer.play()
                    } catch {
                        
                    }
                }
            }
        }
        else {
            // alert user class already exists
            let alert = UIAlertController(title: "The course you entered already existsv.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Sorry, I just love that class", style: UIAlertAction.Style.cancel) { (_) in
                return
            }
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
  
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows
        return classes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // configure the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath)
        let course = classes[indexPath.row]
        // set the text field and style the text
        cell.textLabel?.text = course
        cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // only allow user to edit their own content
        return userEmail == (Auth.auth().currentUser?.email)!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // segue to the features page based on the course that was selected
        currClass = classes[indexPath.row]
        performSegue(withIdentifier: "courseToFeatures", sender: nil)
    }
    
    // editing the table view
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // reference to the current user
            userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
            // reference to the document of classes
            let clasesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes")
            _ = clasesRef?.collection(classes[indexPath.row])
            // remove the selected class from the database
            clasesRef?.updateData([
                "classes": FieldValue.arrayRemove([classes[indexPath.row]])
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                }
            }
            // remove the selected class from the table view
            classes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            
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
        // send current semester, class, and user's email to features page
        let classFeaturesVC = segue.destination as! ClassFeaturesTableViewController
        classFeaturesVC.currSemester = currSemester
        classFeaturesVC.currClass = currClass
        classFeaturesVC.userEmail = userEmail
     }
    
}

