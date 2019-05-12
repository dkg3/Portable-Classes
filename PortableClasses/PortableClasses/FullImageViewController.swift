//
//  FullImageViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/5/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class FullImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var currImage = ""
    var currSemester = ""
    var currClass = ""
    
    var imageView: UIImageView = UIImageView()
    var image: UIImage = UIImage()
    
    var trash:UIBarButtonItem!
    
    var audioPlayer = AVAudioPlayer()

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
                    self.image = UIImage(data: data)!
                    self.imageView = UIImageView(image: self.image)
                    self.imageView.frame = CGRect(x: (self.view.frame.size.width / 2) - (self.image.size.width / 2), y: (self.view.frame.size.height / 2) - (self.image.size.height / 2), width: self.view.frame.size.width / 1.05, height: self.view.frame.size.width / 1.05)
                    self.imageView.center = self.view.center;
                    self.imageView.contentMode = .scaleAspectFit
                    self.view.addSubview(self.imageView)
                }
            }
            catch {
                // error
            }
        }
        self.trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped))
        self.navigationItem.rightBarButtonItem = self.trash
//        scrollView.delegate = self
//        scrollView.minimumZoomScale = 0.5
//        scrollView.maximumZoomScale = 4.0
//        scrollView.zoomScale = 1.0
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
        let path = Bundle.main.path(forResource: "delete", ofType:"wav")!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            print("uh oh")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return self.imageView
//    }

}
