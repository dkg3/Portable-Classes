//
//  FullImageViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/5/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class FullImageViewController: UIViewController {
    
    var currImage = ""
    var currSemester = ""
    var currClass = ""
    
    var trash:UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        print(currImage)
        
        let imageName = currImage
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data.init(contentsOf: URL.init(string:imageName)!)
                DispatchQueue.main.async {
                    let image: UIImage = UIImage(data: data)!
                    let imageView = UIImageView(image: image)
                    imageView.frame = CGRect(x: (self.view.frame.size.width / 2) - (image.size.width / 2), y: (self.view.frame.size.height / 2) - (image.size.height / 2), width: self.view.frame.size.width / 1.05, height: self.view.frame.size.width / 1.05)
                    imageView.center = self.view.center;
                    imageView.contentMode = .scaleAspectFit
                    self.view.addSubview(imageView)
                }
            }
            catch {
                // error
            }
        }
        self.trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped))
        self.navigationItem.rightBarButtonItem = self.trash
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func trashTapped() {
        let db = Firestore.firestore()
        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        let picRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("handNotes")
        
        picRef?.updateData([
            "handNotes": FieldValue.arrayRemove([currImage]),
        ])
        self.dismiss(animated: true, completion: nil)
    }

}
