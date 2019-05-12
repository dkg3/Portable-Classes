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
            if error != nil {
                print("Could not find document")
            }
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print("size = ", self.pics.count)
        return self.pics.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "picCell", for: indexPath) as! CollectionViewCell
    
        // Configure the cell
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data.init(contentsOf: URL.init(string:self.pics[indexPath.row])!)
                DispatchQueue.main.async {
                    let image: UIImage = UIImage(data: data)!
                    cell.imageView.image = image
                }
            }
            catch {
                // error
            }
        }
        
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        imgSelected = indexPath.row
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
//    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
//    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
//        print(indexPath.row, "testing")
//        return false
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
//        print(indexPath.row, "test")
//        return false
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
//    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        
        if let index = indexPath {
            print("Got clicked on index: \(index.row)!")
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
                    if error != nil {
                        print("Could not find document")
                    }
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
            //            if let document = document {
            //                self.pics = document["handNotes"] as? Array ?? [""]
            //                print(self.pics)
            //            }
            if error != nil {
                print("Could not find document")
            }
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
