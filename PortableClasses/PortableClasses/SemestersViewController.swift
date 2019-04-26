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
    
    @IBAction func onAddTapped() {
        let alert = UIAlertController(title: "Add Semester", message: nil, preferredStyle: .alert)
        alert.addTextField {(semesterTF) in
            semesterTF.placeholder = "Enter Semester"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let semester = alert.textFields?.first?.text else {return}
            self.add(semester)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            return
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func add(_ semester: String) {
        let index = 0
        semesters.insert(semester, at: index)
        let indexPath = IndexPath(row: index, section: 0)
        tableView.insertRows(at: [indexPath], with: .left)
    }
    
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
