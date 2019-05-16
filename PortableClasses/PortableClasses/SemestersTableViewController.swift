//
//  SemestersTableViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 4/27/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class SemestersTableViewController: UITableViewController {
    
    var semesters = [String]()
    var currSemester: String = ""
    
    @IBOutlet var semestersTable: UITableView!
    
    var addAction: UIAlertAction!
    
    var audioPlayer = AVAudioPlayer()
    
    
    var userEmail: String! // user from map table.. not logged in user
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Avenir Heavy", size: 20)!]
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(red:1.00, green:0.96, blue:0.41, alpha:1.0)]
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 20)!]
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 20)!]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(red:1.00, green:0.96, blue:0.41, alpha:1.0)]
        
        let db = Firestore.firestore()
        var userRef: DocumentReference? = nil
        print("!!!!!!\(userEmail!)")
        userRef = db.collection("users").document(userEmail!)
        let semestsRef = userRef?.collection("semesters").document("semesters")
        semestsRef!.getDocument { (document, error) in
            if error != nil {}
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

        // preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // only allow user to edit their own content
        if userEmail == (Auth.auth().currentUser?.email)! {
            // display an Edit button in the navigation bar for this view controller.
            self.navigationItem.rightBarButtonItem = self.editButtonItem
            let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
            navigationItem.rightBarButtonItems?.append(add)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    @objc func addTapped() {
        let alert = UIAlertController(title: "Add Semester", message: nil, preferredStyle: .alert)
        self.addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let semester = alert.textFields?.first?.text else {return}
            self.add(semester)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (_) in
            return
        }
        alert.addTextField {(semesterTF) in
            semesterTF.placeholder = "Enter Semester"
            // add event listener to text field to toggle add button
            semesterTF.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: .editingChanged)
        }
        addAction.isEnabled = false
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true)
    }
    
    // enable add button on UIActionController when there is text
    @objc func textFieldChanged(_ textField: UITextField) {
        addAction.isEnabled = textField.text!.count > 0
    }
  
    func add(_ semester: String) {
        // only add semester if not in the user's semester array
        if !self.semesters.contains(semester) {
            let db = Firestore.firestore()
            var userRef: DocumentReference? = nil
            userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
            let semestsRef = userRef?.collection("semesters").document("semesters")
            // append semester
            semestsRef?.updateData([
                "semesters": FieldValue.arrayUnion([semester])
            ]) { err in
                if err != nil {}
                else {
                    // initialize classes array for this semester
                    let classesRef = semestsRef?.collection(semester)
                    let classesDoc = classesRef?.document("classes")
                    classesDoc?.setData([
                        "classes": []
                    ]) { err in
                        if err != nil {}
                        else {
                            let index = self.semesters.count
                            self.semesters.insert(semester, at: index)
                            let indexPath = IndexPath(row: index, section: 0)
                            self.tableView.insertRows(at: [indexPath], with: .left)
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
            }
        }
        else {
            // alert user semester already exists
            let alert = UIAlertController(title: "The semester you entered already exists.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Sorry, I just love that semester", style: UIAlertAction.Style.cancel) { (_) in
                return
            }
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return semesters.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "semesterCell", for: indexPath)
        let semester = semesters[indexPath.row]
        cell.textLabel?.text = semester
        cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return userEmail == (Auth.auth().currentUser?.email)!
    }
    
    // editing the table view
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let db = Firestore.firestore()
            var userRef: DocumentReference? = nil
            userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
            let semestsRef = userRef?.collection("semesters").document("semesters")
            _ = semestsRef?.collection(semesters[indexPath.row])
            semestsRef?.updateData([
                "semesters": FieldValue.arrayRemove([semesters[indexPath.row]])
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                }
            }
            semesters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let path = Bundle.main.path(forResource: "delete", ofType:"wav")!
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
            } catch {
                
            }
        }
    }
    
    // don't allow conditional rearranging of the table view
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // send current semester to classrs page
        let classVC = segue.destination as! ClassesTableViewController
        classVC.currSemester = currSemester
        classVC.userEmail = self.userEmail
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currSemester = semesters[indexPath.row]
        performSegue(withIdentifier: "semesterToCourses", sender: nil)
    }

}
