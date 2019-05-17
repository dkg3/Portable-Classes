//
//  DeadlinesTableViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 5/2/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class DeadlinesTableViewController: UITableViewController {

    // each cell has a deadline name and date stored in 2 separate arrays
    var deadlines = [String]()
    var dates = [String]()
    
    // reference variables to the current semester, class, and student
    var currSemester = ""
    var currClass = ""
    var userEmail:String!
    
    // initial variable for sound
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get access to firebase
        let db = Firestore.firestore()
        var userRef: DocumentReference? = nil
        // reference to the user selected
        userRef = db.collection("users").document(userEmail!)
        // reference to the document of deadlines
        let deadlinesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("deadlines")
        // display the deadline events and dates in the view controller
        deadlinesRef!.getDocument { (document, error) in
            if error != nil {}
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload table once db returns array of semesters
                    DispatchQueue.main.async {
                        self.deadlines = data["deadlines"]! as! [String]
                        self.dates = data["dates"]! as! [String]
                        self.tableView.reloadData()
                    }
                })
            })
        }

        // if the user is on their own deadlines page, display an add and edit button
        if userEmail == (Auth.auth().currentUser?.email)! {
            self.navigationItem.rightBarButtonItem = self.editButtonItem
            let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
            navigationItem.rightBarButtonItems?.append(add)
        }
        
    }
    
    @objc func addTapped() {
        // segue to the add deadlines view when the add button is tapped
        performSegue(withIdentifier: "deadlinesToAdd", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows
        return deadlines.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // configure the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "deadlineCell", for: indexPath)
        // set the text fields for the deadline event and date
        let deadline = deadlines[indexPath.row]
        cell.textLabel?.text = deadline
        let date = dates[indexPath.row]
        cell.detailTextLabel?.text = date
        // style the text
        cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor(red:0.54, green:1.00, blue:0.71, alpha:1.0)
        return cell
    }
    
    // only allow editing if current user displayed is logged in user
    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool {
        return userEmail == (Auth.auth().currentUser?.email)!
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // get access to firebase
            let db = Firestore.firestore()
            var userRef: DocumentReference? = nil
            // reference the current user
            userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
            // reference to the document of deadlines
            let deadlinesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("deadlines")
            // remove the deadline selected from the 2 arrays
            deadlinesRef?.updateData([
                "deadlines": FieldValue.arrayRemove([deadlines[indexPath.row]]), "dates": FieldValue.arrayRemove([dates[indexPath.row]])
            ]) { err in
                if err != nil {}
            }
            
            // play the delete sound when a deadline is removed
            let path = Bundle.main.path(forResource: "delete", ofType:"wav")!
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
            } catch {
                
            }
            
            // update the table view and reload to show updated table
            self.deadlines.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addDeadlinesVC = segue.destination as? AddDeadlineViewController {
            // process the reminder event and date from the callback
            addDeadlinesVC.callback1 = { message, date in
                // make sure there isn't a duplicate deadline
                if !self.deadlines.contains(message) && !self.dates.contains(date) {
                    // get reference to firebase
                    let db = Firestore.firestore()
                    var userRef: DocumentReference? = nil
                    // reference the current user
                    userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
                    // reference to the document of deadlines
                    let deadlinesRef = userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("deadlines")
                    // add the new deadline to firebase
                    deadlinesRef?.updateData([
                        "deadlines": FieldValue.arrayUnion([message]),
                        "dates": FieldValue.arrayUnion([date])
                        ])
                    // add the deadline and date to the arrays and reload the table to display them
                    self.deadlines.append(message)
                    self.dates.append(date)
                    self.tableView.reloadData()
                    return true
                }
                else {
                    // alert user deadline already exists
                    let alert = UIAlertController(title: "The deadline or date you entered already exists.", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) { (_) in
                        return
                    }
                    // show the user the alert
                    alert.addAction(okAction)
                    addDeadlinesVC.present(alert, animated: true)
                    return false
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // reload the table view every time the page appears to display the most current data
        self.tableView.reloadData()
    }

}
