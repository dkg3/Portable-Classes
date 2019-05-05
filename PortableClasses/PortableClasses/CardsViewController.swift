//
//  CardsViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/3/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class CardsViewController: UITableViewController {

    var cards = [String]()
    
    var currSemester = ""
    var currClass = ""
    var currCardsCollection = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        
        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        let flashCardsAllRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("flashcards")
        
        flashCardsAllRef!.getDocument { (document, error) in
            if error != nil {
                print("Could not find document")
            }
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload table once db returns array of flashcard collections
                    DispatchQueue.main.async {
                        self.cards = data["flashcards"]! as! [String]
                        self.tableView.reloadData()
                    }
                })
            })
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cards.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flashcardsCollectionCell", for: indexPath)
        
        let card = cards[indexPath.row]
        cell.textLabel?.text = card
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currCardsCollection = cards[indexPath.row]
        print(currCardsCollection)
        performSegue(withIdentifier: "cardsToCollection", sender: nil)
    }
    
    @IBAction func addTapped() {
        let alert = UIAlertController(title: "Add Collection of Flash Cards", message: nil, preferredStyle: .alert)
        alert.addTextField {(fcCollectionTF) in
            fcCollectionTF.placeholder = "Enter Collection"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let fcCollection = alert.textFields?.first?.text else {return}
            self.add(fcCollection)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (_) in
            return
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true)
    }
    
    func add(_ collection: String) {
        
        let db = Firestore.firestore()
        
        var userRef: DocumentReference? = nil
        
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        let flashCardsAllRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("flashcards")
        // add new flash cards collection
        let newCollection = flashCardsAllRef?.collection(collection)
        print("new \(newCollection!)")
        
        // append collection
        flashCardsAllRef?.updateData([
            "flashcards": FieldValue.arrayUnion([collection])
        ]) { err in
            if err != nil {
                print("Error adding document")
            } else {
                // initialize classes array for this semester
                let newCollectionDoc = newCollection?.document("flashcards")

                newCollectionDoc?.setData([
                    "terms": [],
                    "definitions": []
                ]) { err in
                    if err != nil {
                        print("Error adding document")
                    } else {
                        // add semester to table
                        let index = 0
                        self.cards.insert(collection, at: index)
                        let indexPath = IndexPath(row: index, section: 0)
                        self.tableView.insertRows(at: [indexPath], with: .left)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let collectionVC = segue.destination as! FlashCardsScrollViewController
        collectionVC.currCardsCollection = currCardsCollection
        collectionVC.currClass = currClass
        collectionVC.currSemester = currSemester
    }
}
