//
//  ClassFeaturesTableViewController.swift
//  
//
//  Created by Anthony Ramirez on 5/2/19.
//

import UIKit

class ClassFeaturesTableViewController: UITableViewController {

    @IBOutlet var classFeaturesTable: UITableView!
    
    var classFeatures = [String]()
    var userEmail:String!
    var currSemester = ""
    var currClass = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classFeatures = ["Deadlines", "Notes", "Pictures", "Flash Cards"]
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "deadlinesCell", for: indexPath)
            let feature = classFeatures[indexPath.row]
            cell.textLabel?.text = feature
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
            cell.textLabel?.textColor = UIColor.white
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath)
            let feature = classFeatures[indexPath.row]
            cell.textLabel?.text = feature
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
            cell.textLabel?.textColor = UIColor.white
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "picturesCell", for: indexPath)
            let feature = classFeatures[indexPath.row]
            cell.textLabel?.text = feature
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
            cell.textLabel?.textColor = UIColor.white
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "flashcardsCell", for: indexPath)
            let feature = classFeatures[indexPath.row]
            cell.textLabel?.text = feature
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
            cell.textLabel?.textColor = UIColor.white
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "featuresToDeadlines" {
            let deadlinesVC = segue.destination as! DeadlinesTableViewController
            deadlinesVC.currSemester = currSemester
            deadlinesVC.currClass = currClass
            print("EMAIL FROM CLASS FTS TO DEADLINES: \(self.userEmail!)")
            deadlinesVC.userEmail = userEmail
        }
        else if segue.identifier == "featuresToNotes" {
            let notesVC = segue.destination as! NotesViewController
            notesVC.currSemester = currSemester
            notesVC.currClass = currClass
            notesVC.userEmail = userEmail
        
        }
        else if segue.identifier == "featuresToPics" {
            let picsVC = segue.destination as! PicsCollectionViewController
            picsVC.currSemester = currSemester
            picsVC.currClass = currClass
            picsVC.userEmail = userEmail
        }
        else if segue.identifier == "featuresToCards" {
            let cardsVC = segue.destination as! CardsViewController
            cardsVC.currSemester = currSemester
            cardsVC.currClass = currClass
            cardsVC.userEmail = userEmail
        }
    }

}
