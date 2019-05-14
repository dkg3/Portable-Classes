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

    var deadlines = [String]()
    var dates = [String]()
    
    var currSemester = ""
    var currClass = ""
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        let deadlinesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("deadlines")
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

        // display an edit button on the right side of the nav bar
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItems?.append(add)
    }
    
    @objc func addTapped() {
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
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "deadlineCell", for: indexPath)
        let deadline = deadlines[indexPath.row]
        cell.textLabel?.text = deadline
        let date = dates[indexPath.row]
        cell.detailTextLabel?.text = date
        cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor(red:0.54, green:1.00, blue:0.71, alpha:1.0)
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let db = Firestore.firestore()
            var userRef: DocumentReference? = nil
            userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
            let deadlinesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("deadlines")
            deadlinesRef?.updateData([
                "deadlines": FieldValue.arrayRemove([deadlines[indexPath.row]]), "dates": FieldValue.arrayRemove([dates[indexPath.row]])
            ]) { err in
                if err != nil {}
            }
            
            let path = Bundle.main.path(forResource: "delete", ofType:"wav")!
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
            } catch {
                
            }
            
            self.deadlines.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addDeadlinesVC = segue.destination as? AddDeadlineViewController {
            addDeadlinesVC.callback1 = { message, date in
                if !self.deadlines.contains(message) && !self.dates.contains(date) {
                    let db = Firestore.firestore()
                    var userRef: DocumentReference? = nil
                    userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
                    let deadlinesRef = userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("deadlines")
                    deadlinesRef?.updateData([
                        "deadlines": FieldValue.arrayUnion([message]),
                        "dates": FieldValue.arrayUnion([date])
                        ])
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
                    alert.addAction(okAction)
                    addDeadlinesVC.present(alert, animated: true)
                    return false
                }
            }
            addDeadlinesVC.callback2 = { message in
                if self.dates.contains(message) {
                    let db = Firestore.firestore()
                    var userRef: DocumentReference? = nil
                    userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
                    let datesRef = userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("deadlines")
                    datesRef?.updateData([
                        "dates": FieldValue.arrayUnion([message])
                        ])
                    self.dates.append(message)
                }
                else {
                    // alert user deadline already exists
                    let alert = UIAlertController(title: "There is already a deadline at the time you entered.", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) { (_) in
                        return
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                }  
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

}
