//
//  FlashCardsScrollViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 5/5/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class FlashCardsScrollViewController: UIViewController, UIScrollViewDelegate {
    
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create pages for each flash card
        pages = createFlashcards()
        setupScrollView(pages: pages)
        pageControl.numberOfPages = pages.count
        
        pageControl.currentPage = 0
    
        
        view.bringSubviewToFront(pageControl)
        
//        self.navigationController?.navigationBar.layer.zPosition = 1000
        
        self.navigationItem.title = currCardsCollection
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        self.navigationItem.rightBarButtonItems?.append(add)
        print("CURRRRR!!!!!!! \(currCardsCollection)")
        
        
        /*
        let db = Firestore.firestore()
        
        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        let deadlinesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("deadlines")
        
        deadlinesRef!.getDocument { (document, error) in
            if error != nil {
                print("Could not find document")
            }
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload table once db returns array of semesters
                    DispatchQueue.main.async {
                        self.deadlines = data["deadlines"]! as! [String]
                        self.dates = data["dates"]! as! [String]
                        self.tableView.reloadData()
                    }
                })
            })
        }
 */
        
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
        for i in 0 ..< 3{
            cards.append(Bundle.main.loadNibNamed("FlashCard", owner: self, options: nil)?.first as! FlashCard)
            (cards[i] as FlashCard).label.text = "Hello" + String(i)
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
            
            button.backgroundColor = .black
        
            button.center = self.view.center
            button.setTitle("Press to reveal definition", for: .normal)
            button.addTarget(self, action:#selector(self.revealDefinition), for: .touchUpInside)
            
            pages[i].addSubview(button)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    
    @objc func revealDefinition() {
        
        print("FLIP")
        if reveal {
            reveal = false
            
//            UIView.transition(with: pages[pageControl.currentPage].subviews[1], duration: 0.8, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            UIView.transition(with: scrollView, duration: 0.8, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            
            pages[pageControl.currentPage].label.text = "HELLO " + String(pageControl.currentPage)
            
        }
        else {
            reveal = true;
            
            
//            UIView.transition(with: pages[pageControl.currentPage].subviews[1], duration: 0.8, options: .transitionFlipFromRight, animations: nil, completion: nil)
            UIView.transition(with: scrollView, duration: 0.8, options: .transitionFlipFromRight, animations: nil, completion: nil)
            
            
            pages[pageControl.currentPage].label.text = "BYE " + String(pageControl.currentPage)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
//        self.navigationController?.hidesBarsOnTap = true
        
    
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        setupScrollView(pages: pages)
        
        print(pages.count)
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
