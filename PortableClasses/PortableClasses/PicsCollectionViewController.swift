//
//  PicsCollectionViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/4/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PicsCollectionViewController: UICollectionViewController {
    
    var pics = [String]()
    
    var currSemester = ""
    var currClass = ""
    
    var toggle = false
    var imgSelected = -1
    
    let images = ["iTunesArtwork", "iTunesArtwork", "iTunesArtwork", "iTunesArtwork", "iTunesArtwork", "iTunesArtwork", "iTunesArtwork", "iTunesArtwork", "iTunesArtwork"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        let width = (view.frame.size.width - 3) / 3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "picCell", for: indexPath) as! CollectionViewCell
    
        // Configure the cell
        let image = UIImage(named: images[indexPath.row])
        cell.imageView.image = image
        
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        toggle = true
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
////        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
////        let image = UIImage(named: images[indexPath.row])
////        imageView.image = image
////        self.view.addSubview(imageView)
//        print(indexPath.row)
//    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        
        if toggle {
            if let index = indexPath {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
                let image = UIImage(named: images[index.row])
                imageView.image = image
                self.view.addSubview(imageView)
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                print("Got clicked on index: \(index.row)!")
                toggle = false
            }
        }
        else {
            self.view.viewWithTag(100)?.removeFromSuperview()
            toggle = true
            print("ok")
        }
        
    }
 

}
