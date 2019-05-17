//
//  ClassFeaturesTableViewController.swift
//  
//
//  Created by Anthony Ramirez on 5/2/19.
//

import UIKit

class ClassFeaturesTableViewController: UITableViewController {

    // variable to access the features table
    @IBOutlet var classFeaturesTable: UITableView!
    
    // array of features for each class
    var classFeatures = [String]()
    // the current semester and course selected
    var currSemester = ""
    var currClass = ""
    // user from map table, not the logged in user
    var userEmail:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // populate the features array with 4 sections
        classFeatures = ["Deadlines", "Notes", "Pictures", "Flash Cards"]
        // set the nav title to the current course name
        self.navigationItem.title = currClass
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows
        return classFeatures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            // deadlines cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "deadlinesCell", for: indexPath)
            cell.textLabel?.text = classFeatures[indexPath.row]
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
            cell.textLabel?.textColor = UIColor.white
            return cell
        case 1:
            // notes cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath)
            cell.textLabel?.text = classFeatures[indexPath.row]
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
            cell.textLabel?.textColor = UIColor.white
            return cell
        case 2:
            // pictures cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "picturesCell", for: indexPath)
            cell.textLabel?.text = classFeatures[indexPath.row]
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
            cell.textLabel?.textColor = UIColor.white
            return cell
        case 3:
            // flash cards cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "flashcardsCell", for: indexPath)
            cell.textLabel?.text = classFeatures[indexPath.row]
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
            cell.textLabel?.textColor = UIColor.white
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if deadlines is selected
        if segue.identifier == "featuresToDeadlines" {
            // pass the current semester, class, and user's email to the new view controller
            let deadlinesVC = segue.destination as! DeadlinesTableViewController
            deadlinesVC.currSemester = currSemester
            deadlinesVC.currClass = currClass
            deadlinesVC.userEmail = userEmail
        }
        // if notes is selected
        else if segue.identifier == "featuresToNotes" {
            // pass the current semester, class, and user's email to the new view controller
            let notesVC = segue.destination as! NotesViewController
            notesVC.currSemester = currSemester
            notesVC.currClass = currClass
            notesVC.userEmail = userEmail
        }
        // if pictures is selected
        else if segue.identifier == "featuresToPics" {
            // pass the current semester, class, and user's email to the new view controller
            let picsVC = segue.destination as! PicsCollectionViewController
            picsVC.currSemester = currSemester
            picsVC.currClass = currClass
            picsVC.userEmail = userEmail
        }
        // if flash cards is selected
        else if segue.identifier == "featuresToCards" {
            // pass the current semester, class, and user's email to the new view controller
            let cardsVC = segue.destination as! CardsViewController
            cardsVC.currSemester = currSemester
            cardsVC.currClass = currClass
            cardsVC.userEmail = userEmail
        }
    }

}
