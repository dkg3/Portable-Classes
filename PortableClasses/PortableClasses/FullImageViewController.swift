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
    
    // variable with access to scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    
    // variables for current image selected, semester, and class
    var currImage = ""
    var currSemester = ""
    var currClass = ""
    // user's email
    var userEmail: String!
    
    // global access to the image and image view
    var imageView: UIImageView = UIImageView()
    var image: UIImage = UIImage()
    
    // trash button variable
    var trash:UIBarButtonItem!
    
    // initial variable for sound
    var audioPlayer = AVAudioPlayer()
    
    // image scaled variable
    var previousScale:CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // set the style of the nav bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        // set the image to the image passed into the script
        let imageName = currImage
        // asyncronously display the full image while maintaining
        // aspect ratio and centering it to the page
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
                
            }
        }
        // only allow user to edit their own content
        if userEmail == (Auth.auth().currentUser?.email)! {
            // ability to delete the selected image
            self.trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped))
            self.navigationItem.rightBarButtonItem = self.trash
        }
       
        // add gestures to zoom and scroll in all directions
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(sender:)))
        self.view.addGestureRecognizer(gesture)
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(sender:)))
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(sender:)))
        left.direction = .left
        let up = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(sender:)))
        up.direction = .up
        let down = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(sender:)))
        down.direction = .down
        self.view.addGestureRecognizer(right)
        self.view.addGestureRecognizer(left)
        self.view.addGestureRecognizer(up)
        self.view.addGestureRecognizer(down)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        // dismiss the view controller
        self.dismiss(animated: true, completion: nil)
    }

    @objc func trashTapped() {
        // get reference to firebase
        let db = Firestore.firestore()
        var userRef: DocumentReference? = nil
        // reference to the current user
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        // reference to the document of handNotes
        let picRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("handNotes")
        // remove the image from the database
        picRef?.updateData([
            "handNotes": FieldValue.arrayRemove([currImage]),
        ])
        // play the delete sound when removing the image
        let path = Bundle.main.path(forResource: "delete", ofType:"wav")!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            
        }
        // dismiss the view controller
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func pinchAction(sender: UIPinchGestureRecognizer) {
        // scale the view but limit the user from zoom too far out or in
        if previousScale * sender.scale >= 0.8 && previousScale * sender.scale <= 4.0 {
            let scale:CGFloat = previousScale * sender.scale
            self.view.transform = CGAffineTransform(scaleX: scale, y: scale);
            previousScale = sender.scale
        }
    }
    
    @objc func swipeAction(sender: UISwipeGestureRecognizer) {
        // left swipe
        if (sender.direction == .left) {
            // move the image left
            let labelPosition = CGPoint(x: self.view.frame.origin.x - 100.0, y: self.view.frame.origin.y)
            // make the movement smooth my animating the change in position
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            })
        }
        // right swipe
        else if (sender.direction == .right) {
            // move the image right
            let labelPosition = CGPoint(x: self.view.frame.origin.x + 100.0, y: self.view.frame.origin.y)
            // make the movement smooth my animating the change in position
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            })
        }
        // up swipe
        else if (sender.direction == .up) {
            // move the image up
            let labelPosition = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.origin.y - 100.0)
            // make the movement smooth my animating the change in position
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            })
        }
        // down swipe
        else if (sender.direction == .down) {
            // move the image down
            let labelPosition = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.origin.y + 100.0)
            // make the movement smooth my animating the change in position
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            })
        }
    }

}
