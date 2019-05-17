//
//  FlashCardsScrollViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 5/5/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class FlashCardsScrollViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    
    // variables accessing the scroll view and page control
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // array of flash cards
    var pages:[FlashCard] = []
    // flag to reveal term or definition
    var reveal:Bool = false
    // flashcard property variables
    var cardView: UIView!
    var term: UILabel!
    var button: UIButton!
    
    // variables for the current semester, class, and flash card collection
    var currSemester = ""
    var currClass = ""
    var currCardsCollection = ""
    // user's email
    var userEmail: String!
    
    // number of cards, terms, definitons, and revealed arrays
    var numCards:Int = 0
    var terms:[String] = []
    var definitions:[String] = []
    var revealed:[Bool] = []
    
    // trash button
    var trash:UIBarButtonItem!
    
    // initial variable for sound
    var audioPlayer = AVAudioPlayer()
    
    // get access to firebase
    let db = Firestore.firestore()
    var userRef: DocumentReference? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // have page control always show and make nav title the collection name
        view.bringSubviewToFront(pageControl)
        self.navigationItem.title = currCardsCollection
        
        // only allow user to edit their own content
        if userEmail == (Auth.auth().currentUser?.email)! {
            // have an add and trash button
            let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
            self.trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped))
            self.navigationItem.rightBarButtonItem = self.trash
            self.navigationItem.rightBarButtonItems?.append(add)
        }
        // get flashcard info
        getInfoFromDB()
    }
    
    @objc func addTapped() {
        // segue to add flashcard view
        performSegue(withIdentifier: "cardsToAdd", sender: nil)
    }
    
    @objc func trashTapped() {
        // reference to current user
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        // reference to the document of flashcards
        let fcRef = userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("flashcards").collection(self.currCardsCollection).document("flashcards")
        // add the term and definition to the database
        fcRef?.updateData([
            "terms": FieldValue.arrayRemove([terms[self.pageControl.currentPage]]),
            "definitions": FieldValue.arrayRemove([definitions[self.pageControl.currentPage]])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            }
            else {
                // update scroll view
                DispatchQueue.main.async {
                    self.terms.remove(at: self.pageControl.currentPage)
                    self.definitions.remove(at: self.pageControl.currentPage)
                    if self.terms.count == 0 {
                        self.pages[0].textView.text = ""
                        self.pages[0].label.text = ""
                        self.navigationItem.rightBarButtonItems?[0].isEnabled = false
                        self.pageControl.numberOfPages = 0
                        self.button.isHidden = true
                    }
                    else {
                        self.numCards = self.terms.count
                        self.pages = self.createFlashcards()
                        self.setupScrollView(pages: self.pages)
                        self.pageControl.numberOfPages = self.pages.count
                        self.pageControl.currentPage = 0
                        self.view.bringSubviewToFront(self.pageControl)
                    }
                }
            }
        }
        // play the delete sound when deleting a flashcard
        let path = Bundle.main.path(forResource: "delete", ofType:"wav")!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            
        }
    }
    
    func createFlashcards() -> [FlashCard] {
        var cards:[FlashCard] = []
        for i in 0 ..< terms.count {
            // add the term and definition to the new flashcard
            cards.append(Bundle.main.loadNibNamed("FlashCard", owner: self, options: nil)?.first as! FlashCard)
            (cards[i] as FlashCard).label.text = terms[i]
            (cards[i] as FlashCard).textView.text = definitions[i]
            // hide the definition at first
            (cards[i] as FlashCard).textView.isHidden = true
            revealed.append(false)
        }
        return cards
    }
    
    func setupScrollView(pages : [FlashCard]) {
        // structure the scroll view
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(pages.count), height: 1.0)
        // enable paging
        scrollView.isPagingEnabled = true
        for i in 0 ..< pages.count {
            pages[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(pages[i])
            // add a toggle button to switch between term and definition
            button = UIButton(frame: CGRect(x: view.frame.width/2 - 90, y: view.frame.height - 350, width: 180, height: 40))
            button.backgroundColor = .red
            button.setTitle("Tap to toggle", for: .normal)
            button.addTarget(self, action:#selector(self.revealDefinition), for: .touchUpInside)
            pages[i].addSubview(button)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // get the current indec of the page control
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    
    @objc func revealDefinition() {
        reveal = revealed[pageControl.currentPage]
        // toggle between term and definition
        if reveal {
            reveal = false
            // animate the transition
            UIView.transition(with: scrollView, duration: 0.8, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            // hide the definition
            pages[pageControl.currentPage].label.isHidden = false
            pages[pageControl.currentPage].textView.isHidden = true
        }
        else {
            reveal = true
            // animate the transition
            UIView.transition(with: scrollView, duration: 0.8, options: .transitionFlipFromRight, animations: nil, completion: nil)
            // hide the term
            pages[pageControl.currentPage].label.isHidden = true
            pages[pageControl.currentPage].textView.isHidden = false
        }
        
        // play the flip sound when flipping a flashcard
        let path = Bundle.main.path(forResource: "flip", ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            
        }
        
        // show the current flashcard
        let result = revealed[pageControl.currentPage]
        revealed[pageControl.currentPage] = !result
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // number of flashcards
        pageControl.numberOfPages = pages.count
        // get flashcard info
        getInfoFromDB()
    }
    
    func getInfoFromDB() {
        // reference to the user's email
        userRef = db.collection("users").document(userEmail!)
        // reference to the document of flashcards
        let fcRef = userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("flashcards").collection(self.currCardsCollection).document("flashcards")
        // access all the flashcards from the database
        fcRef!.getDocument { (document, error) in
            if error != nil {}
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload scroll view once db returns array of flash cards
                    DispatchQueue.main.async {
                        // set the terms, definitions, number of cards/pages
                        // set up the scroll view and page control
                        self.terms = data["terms"]! as! [String]
                        self.definitions = data["definitions"] as! [String]
                        self.numCards = self.terms.count
                        self.pages = self.createFlashcards()
                        self.setupScrollView(pages: self.pages)
                        self.pageControl.numberOfPages = self.pages.count
                        self.view.bringSubviewToFront(self.pageControl)
                        // enable trash button when there is something to delete
                        if self.numCards > 0 {
                            self.navigationItem.rightBarButtonItems?[0].isEnabled = true
                        }
                        else {
                           self.navigationItem.rightBarButtonItems?[0].isEnabled = false
                        }
                        
                    }
                })
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addFlashCardslinesVC = segue.destination as? AddFlashCardViewController {
            // callback from add flashcard
            addFlashCardslinesVC.callback1 = { message, definition in
                // no duplicates allowed
                if !self.terms.contains(message) && !self.definitions.contains(definition) {
                    // reference to the user's email
                    self.userRef = self.db.collection("users").document(self.userEmail!)
                    // reference to the document of flashcards
                    let fcRef = self.userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("flashcards").collection(self.currCardsCollection).document("flashcards")
                    // append term and definition
                    fcRef?.updateData([
                        "terms": FieldValue.arrayUnion([message]),
                        "definitions": FieldValue.arrayUnion([definition])
                    ]) { err in
                        if err != nil {}
                    }
                    // add the new flashcard
                    let newFC = Bundle.main.loadNibNamed("FlashCard", owner: self, options: nil)?.first as! FlashCard
                    newFC.label.text = message
                    self.pages.append(newFC)
                    return true
                }
                else {
                    // alert user deadline already exists
                    let alert = UIAlertController(title: "The term or definition you entered already exists.", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) { (_) in
                        return
                    }
                    // display the alert to the user
                    alert.addAction(okAction)
                    addFlashCardslinesVC.present(alert, animated: true)
                    return false
                }
            }
        }
    }
    
}
