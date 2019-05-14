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
    
    var pics = [String]()
    
    var currSemester = ""
    var currClass = ""
    
    var imgSelected = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // Do any additional setup after loading the view.
        let width = (view.frame.size.width - 3) / 3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        
        let db = Firestore.firestore()
        let allUsersRef: CollectionReference? = db.collection("users")
        let currUserRef: DocumentReference? = allUsersRef?.document((Auth.auth().currentUser?.email)!).collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("handNotes")
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
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        imgSelected = indexPath.row
        return cell
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        if let index = indexPath {
            imgSelected = index.row
            performSegue(withIdentifier: "imgToFullImg", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imgToFullImg" {
            let nav = segue.destination as! UINavigationController
            let fullImgVC = nav.topViewController as! FullImageViewController
            fullImgVC.currImage = self.pics[imgSelected]
            fullImgVC.currSemester = currSemester
            fullImgVC.currClass = currClass
        }
        else if segue.identifier == "newImg" {
            let nav = segue.destination as! UINavigationController
            let picsVC = nav.topViewController as! CameraViewController
            picsVC.callback = {message in
                let db = Firestore.firestore()
                let allUsersRef: CollectionReference? = db.collection("users")
                let currUserRef: DocumentReference? = allUsersRef?.document((Auth.auth().currentUser?.email)!).collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("handNotes")
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
            picsVC.currSemester = currSemester
            picsVC.currClass = currClass
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let db = Firestore.firestore()
        let allUsersRef: CollectionReference? = db.collection("users")
        let currUserRef: DocumentReference? = allUsersRef?.document((Auth.auth().currentUser?.email)!).collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("handNotes")
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
