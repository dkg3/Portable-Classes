//
//  SemestersTableViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 4/27/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class SemestersTableViewController: UITableViewController {
    
    var semesters = [String]()
    var currSemester: String = ""
    
    @IBOutlet var semestersTable: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem = self.addButton
        
        
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
        // add new semester collection
        let newSemesterCollection = semestsRef?.collection(semester)
        print("new \(newSemesterCollection!)")
        
        // append semester
        semestsRef?.updateData([
            "semesters": FieldValue.arrayUnion([semester])
        ]) { err in
            if err != nil {
                print("Error adding document")
            } else {
                // initialize classes array for this semester
                let classesRef = semestsRef?.collection(semester)
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
        return cell
    }
 

    
    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
//        return true
//    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        
            let db = Firestore.firestore()
            
            var userRef: DocumentReference? = nil
            userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
            
            let semestsRef = userRef?.collection("semesters").document("semesters")
            // TODO: finish deleting collection if possible
            _ = semestsRef?.collection(semesters[indexPath.row])
            
            semestsRef?.updateData([
                "semesters": FieldValue.arrayRemove([semesters[indexPath.row]])
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
            }
        
            
            semesters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
 

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // send current semester to classrs page
        let classVC = segue.destination as! ClassesTableViewController
        classVC.currSemester = currSemester

    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currSemester = semesters[indexPath.row]
        print(currSemester)
    }

}
