//
//  PicsCollectionViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/4/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI

private let reuseIdentifier = "Cell"

class PicsCollectionViewController: UICollectionViewController {
    
    // array of images
    var pics = [String]()
    // variable for the current semester and class
    var currSemester = ""
    var currClass = ""
    // current user's email
    var userEmail: String!
    
    // variable to know the index of the image selected for full view
    var imgSelected = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        // register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // do any additional setup after loading the view
        let width = (view.frame.size.width - 3) / 3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        // get reference to firebase
        let db = Firestore.firestore()
        // reference to all the users
        let allUsersRef: CollectionReference? = db.collection("users")
        // reference to the document of handNotes
        let currUserRef: DocumentReference? = allUsersRef?.document(userEmail!).collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("handNotes")
        // get all the images of the user
        currUserRef?.getDocument { (document, error) in
            if error != nil {}
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload table once db returns array of pictures
                    DispatchQueue.main.async {
                        self.pics = data["handNotes"]! as! [String]
                        self.collectionView.reloadData()
                    }
                })
            })
        }
        
        // only allow user to edit their own content
        if userEmail == (Auth.auth().currentUser?.email)! {
            // display an Edit button in the navigation bar for this view controller
            let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
            self.navigationItem.rightBarButtonItem = add
        }
    }

    @objc func addTapped() {
        // go to the add image view controller
        performSegue(withIdentifier: "newImg", sender: self)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // number of items
        return self.pics.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "picCell", for: indexPath) as! CollectionViewCell
        // asyncronously display the images
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data.init(contentsOf: URL.init(string:self.pics[indexPath.row])!)
                DispatchQueue.main.async {
                    let image: UIImage = UIImage(data: data)!
                    cell.imageView.image = image
                }
            }
            catch {
                
            }
        }
        // add a tap gesture to each image
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        imgSelected = indexPath.row
        return cell
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        // go to the full view of the selected image when tapped
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        if let index = indexPath {
            imgSelected = index.row
            performSegue(withIdentifier: "imgToFullImg", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // going to full view controller
        if segue.identifier == "imgToFullImg" {
            // pass the selected image, current semester, class, and user's email
            let nav = segue.destination as! UINavigationController
            let fullImgVC = nav.topViewController as! FullImageViewController
            fullImgVC.currImage = self.pics[imgSelected]
            fullImgVC.currSemester = currSemester
            fullImgVC.currClass = currClass
            fullImgVC.userEmail = userEmail
        }
        // going to add image controller
        else if segue.identifier == "newImg" {
            let nav = segue.destination as! UINavigationController
            let picsVC = nav.topViewController as! CameraViewController
            picsVC.callback = {message in
                // get reference to firebase
                let db = Firestore.firestore()
                // reference to all the users
                let allUsersRef: CollectionReference? = db.collection("users")
                // reference to the document of handNotes
                let currUserRef: DocumentReference? = allUsersRef?.document((Auth.auth().currentUser?.email)!).collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("handNotes")
                // get all the images of the user
                currUserRef?.getDocument { (document, error) in
                    if error != nil {}
                    _ = document.flatMap({
                        $0.data().flatMap({ (data) in
                            // asynchronously reload table once db returns array of pictures
                            DispatchQueue.main.async {
                                self.pics = data["handNotes"]! as! [String]
                                self.collectionView.reloadData()
                            }
                        })
                    })
                }
            }
            // set the current semester an class
            picsVC.currSemester = currSemester
            picsVC.currClass = currClass
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // get reference to firebase
        let db = Firestore.firestore()
        // reference to all the users
        let allUsersRef: CollectionReference? = db.collection("users")
        // reference to the document of handNotes
        let currUserRef: DocumentReference? = allUsersRef?.document((Auth.auth().currentUser?.email)!).collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("handNotes")
        // get all the images of the user
        currUserRef?.getDocument { (document, error) in
            if error != nil {}
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload table once db returns array of pictures
                    DispatchQueue.main.async {
                        self.pics = data["handNotes"]! as! [String]
                        self.collectionView.reloadData()
                    }
                })
            })
        }
    }

}
