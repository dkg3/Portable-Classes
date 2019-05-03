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
    var currSemester = ""
    var currClass = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        classFeatures = ["Deadlines", "Notes", "Pictures", "Flash Cards"]
        
        self.navigationItem.title = currClass
        print(currSemester, currClass)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return classFeatures.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "flashcardsCell", for: indexPath)
//
//        let feature = classFeatures[indexPath.row]
//        cell.textLabel?.text = feature
//
//        return cell
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "deadlinesCell", for: indexPath)
            let feature = classFeatures[indexPath.row]
            cell.textLabel?.text = feature
            print(0)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath)
            let feature = classFeatures[indexPath.row]
            cell.textLabel?.text = feature
            print(1)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "picturesCell", for: indexPath)
            let feature = classFeatures[indexPath.row]
            cell.textLabel?.text = feature
            print(2)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "flashcardsCell", for: indexPath)
            let feature = classFeatures[indexPath.row]
            cell.textLabel?.text = feature
            print(3)
            return cell

        default:
            return UITableViewCell()
        }
    
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let deadlinesVC = segue.destination as! DeadlinesTableViewController
//        deadlinesVC.currSemester = currSemester
//        deadlinesVC.currClass = currClass
        
        
        let notesVC = segue.destination as! NotesViewController
        notesVC.currSemester = currSemester
        notesVC.currClass = currClass
        
        
//        let picsVC = segue.destination as! PicsViewController
//        picsVC.currSemester = currSemester
//        picsVC.currClass = currClass
        
        
//        let cardsVC = segue.destination as! CardsViewController
//        cardsVC.currSemester = currSemester
//        cardsVC.currClass = currClass
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//    }
    

}
