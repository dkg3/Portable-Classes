//
//  FlashCardsScrollViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 5/5/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class FlashCardsScrollViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var pages:[FlashCard] = []
    var reveal:Bool = false
    var cardView: UIView!
    var term: UILabel!
    var button: UIButton!
    
    var currSemester = ""
    var currClass = ""
    var currCardsCollection = ""
    
    var numCards = 0
    var terms:[String] = []
    var definitions:[String] = []
    
    var revealed:[Bool] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.bringSubviewToFront(pageControl)
        
        
        self.navigationItem.title = currCardsCollection
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        self.navigationItem.rightBarButtonItems?.append(add)
        
        
        
        let db = Firestore.firestore()
        
        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        let fcRef = userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("flashcards").collection(self.currCardsCollection).document("flashcards")
        fcRef!.getDocument { (document, error) in
            if error != nil {
                print("Could not find document")
            }
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload table once db returns array of semesters
                    DispatchQueue.main.async {
                        self.terms = data["terms"]! as! [String]
                        
                        self.definitions = data["definitions"] as! [String]
                    
                        
                        self.numCards = self.terms.count
                        
                        self.pages = self.createFlashcards()
                        self.setupScrollView(pages: self.pages)
                        self.pageControl.numberOfPages = self.pages.count
                        
//                        self.pageControl.currentPage = 0
                        
                        
                        self.view.bringSubviewToFront(self.pageControl)
                        
                    }
                })
            })
        }
 
 
        
    }
    @objc func addTapped() {
        /*
        let alert = UIAlertController(title: "Add Flash Card", message: nil, preferredStyle: .alert)
        alert.addTextField {(semesterTF) in
            semesterTF.placeholder = "Enter Semester"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let fc = alert.textFields?.first?.text else {return}
            self.add(fc)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (_) in
            return
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true)
        */
        
        performSegue(withIdentifier: "cardsToAdd", sender: nil)
        
    }
    
    func addFC(_ fc: String) {
        
        
        
        
        
       
        
        /*
        let db = Firestore.firestore()
        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        
        let fcRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("flashcards").collection(currCardsCollection).document("flashcards")
        
        // append semester
        fcRef?.updateData([
            "terms": FieldValue.arrayUnion([fc])
        ]) { err in
            if err != nil {
                print("Error adding document")
            } 
        }
        
        */
    }
    
    
    func createFlashcards() -> [FlashCard] {
        var cards:[FlashCard] = []
        for i in 0 ..< terms.count {
            cards.append(Bundle.main.loadNibNamed("FlashCard", owner: self, options: nil)?.first as! FlashCard)
            
            (cards[i] as FlashCard).label.text = terms[i]
            
            (cards[i] as FlashCard).textView.text = definitions[i]
            (cards[i] as FlashCard).textView.isHidden = true
            
            revealed.append(false)
            
            print("lala \(cards[i] as FlashCard).textView.text)")
        }
        return cards
    }
    
    func setupScrollView(pages : [FlashCard]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(pages.count), height: 1.0)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< pages.count {
            pages[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(pages[i])
            
            
            button = UIButton(frame: CGRect(x: 0
                , y: 0, width: 260, height: 60))
            
            button.backgroundColor = .yellow
        
            button.center = self.view.center
            button.setTitle("Tap to toggle", for: .normal)
            button.addTarget(self, action:#selector(self.revealDefinition), for: .touchUpInside)
            
            pages[i].addSubview(button)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    
    @objc func revealDefinition() {
        
        reveal = revealed[pageControl.currentPage]
        
        print("FLIP")
        if reveal {
            reveal = false
            
//            self.button.setTitle("Press to reveal term",for: .normal)
            
            UIView.transition(with: scrollView, duration: 0.8, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            
        
            pages[pageControl.currentPage].label.isHidden = false
            pages[pageControl.currentPage].textView.isHidden = true
            
        }
        else {
            reveal = true;
            
            self.button.setTitle("Press to reveal definition",for: .normal)
            
            UIView.transition(with: scrollView, duration: 0.8, options: .transitionFlipFromRight, animations: nil, completion: nil)
            
            pages[pageControl.currentPage].label.isHidden = true
            pages[pageControl.currentPage].textView.isHidden = false
        
           
        }
        
        let result = revealed[pageControl.currentPage]
        revealed[pageControl.currentPage] = !result
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
//        self.navigationController?.hidesBarsOnTap = true
        
    
        pageControl.numberOfPages = pages.count
//        pageControl.currentPage = 0
//        setupScrollView(pages: pages)
        
        let db = Firestore.firestore()
        
        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        let fcRef = userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("flashcards").collection(self.currCardsCollection).document("flashcards")
        fcRef!.getDocument { (document, error) in
            if error != nil {
                print("Could not find document")
            }
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload table once db returns array of semesters
                    DispatchQueue.main.async {
                        self.terms = data["terms"]! as! [String]
                        print("TERMS!!!! \(self.terms)")
                        self.definitions = data["definitions"] as! [String]
                        print("DEFS!!!! \(self.definitions)")
                        
                        self.numCards = self.terms.count
                        
                        self.pages = self.createFlashcards()
                        self.setupScrollView(pages: self.pages)
                        self.pageControl.numberOfPages = self.pages.count
                        
                        //                        self.pageControl.currentPage = 0
                        
                        
                        self.view.bringSubviewToFront(self.pageControl)
                        
                    }
                })
            })
        }
    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        self.navigationController?.hidesBarsOnTap = false
//    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addFlashCardslinesVC = segue.destination as? AddFlashCardViewController {
            addFlashCardslinesVC.callback1 = { message in
                
                
                
                
                let db = Firestore.firestore()
                var userRef: DocumentReference? = nil
                userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
                
                let fcRef = userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("flashcards").collection(self.currCardsCollection).document("flashcards")
                
                // append term
                fcRef?.updateData([
                    "terms": FieldValue.arrayUnion([message])
                ]) { err in
                    if err != nil {
                        print("Error adding document")
                    }
                }
                
                
                let newFC = Bundle.main.loadNibNamed("FlashCard", owner: self, options: nil)?.first as! FlashCard
                newFC.label.text = message
                self.pages.append(newFC)
 
            }
            
            
            addFlashCardslinesVC.callback2 = { message in
                let db = Firestore.firestore()
                var userRef: DocumentReference? = nil
                userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
                
                let fcRef = userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("flashcards").collection(self.currCardsCollection).document("flashcards")
                
                // append term
                fcRef?.updateData([
                    "definitions": FieldValue.arrayUnion([message])
                ]) { err in
                    if err != nil {
                        print("Error adding document")
                    }
                }
                
                /*
                 let newFC = Bundle.main.loadNibNamed("FlashCard", owner: self, options: nil)?.first as! FlashCard
                 newFC.label.text = fc
                 self.pages.append(newFC)
                 */
            }
        }
    }
}
