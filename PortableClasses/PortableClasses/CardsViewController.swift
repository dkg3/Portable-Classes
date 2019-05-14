//
//  CardsViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/3/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class CardsViewController: UITableViewController {

    var cards = [String]()
    
    var currSemester = ""
    var currClass = ""
    var currCardsCollection = ""
    
    var addAction:UIAlertAction!
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let db = Firestore.firestore()
        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        let flashCardsAllRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("flashcards")
        flashCardsAllRef!.getDocument { (document, error) in
            if error != nil {}
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
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItems?.append(add)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows
        return cards.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flashcardsCollectionCell", for: indexPath)
        let card = cards[indexPath.row]
        cell.textLabel?.text = card
        cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
        cell.textLabel?.textColor = UIColor.white
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currCardsCollection = cards[indexPath.row]
        performSegue(withIdentifier: "cardsToCollection", sender: nil)
    }
    
    @objc func addTapped() {
        let alert = UIAlertController(title: "Add Collection of Flash Cards", message: nil, preferredStyle: .alert)
        alert.addTextField {(fcCollectionTF) in
            fcCollectionTF.placeholder = "Enter Collection"
            // add event listener to text field to toggle add button
            fcCollectionTF.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: .editingChanged)
        }
        self.addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let fcCollection = alert.textFields?.first?.text else {return}
            self.add(fcCollection)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (_) in
            return
        }
        addAction.isEnabled = false
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true)
    }
    
    func add(_ collection: String) {
        if !self.cards.contains(collection) {
            let db = Firestore.firestore()
            var userRef: DocumentReference? = nil
            userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
            let flashCardsAllRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("flashcards")
            // add new flash cards collection
            let newCollection = flashCardsAllRef?.collection(collection)
            // append collection
            flashCardsAllRef?.updateData([
                "flashcards": FieldValue.arrayUnion([collection])
            ]) { err in
                if err != nil {}
                else {
                    // initialize classes array for this semester
                    let newCollectionDoc = newCollection?.document("flashcards")
                    newCollectionDoc?.setData([
                        "terms": [],
                        "definitions": []
                    ]) { err in
                        if err != nil {}
                        else {
                            // add semester to table
                            let index = self.cards.count
                            self.cards.insert(collection, at: index)
                            let indexPath = IndexPath(row: index, section: 0)
                            self.tableView.insertRows(at: [indexPath], with: .left)
                        }
                    }
                }
            }
            let path = Bundle.main.path(forResource: "add", ofType:"mp3")!
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
            } catch {
                
            }
        }
        else {
            // alert user class already exists
            let alert = UIAlertController(title: "The collection you entered already exists.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) { (_) in
                return
            }
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        addAction.isEnabled = textField.text!.count > 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let db = Firestore.firestore()
            var userRef: DocumentReference? = nil
            userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
            let fcRef = userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("flashcards")
            _ = fcRef?.collection(cards[indexPath.row])
            fcRef?.updateData([
                "flashcards": FieldValue.arrayRemove([cards[indexPath.row]])
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                }
            }
            
            let path = Bundle.main.path(forResource: "delete", ofType:"wav")!
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
            } catch {
                
            }
            
            cards.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let collectionVC = segue.destination as! FlashCardsScrollViewController
        collectionVC.currCardsCollection = currCardsCollection
        collectionVC.currClass = currClass
        collectionVC.currSemester = currSemester
    }
    
}
