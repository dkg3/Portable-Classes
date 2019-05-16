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
    
    var userEmail:String!
    var currImage = ""
    var currSemester = ""
    var currClass = ""
    
    var imageView: UIImageView = UIImageView()
    var image: UIImage = UIImage()
    
    var trash:UIBarButtonItem!
    
    var audioPlayer = AVAudioPlayer()
    
    var previousScale:CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
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
                
            }
        }
        // only allow user to edit their own content
        if userEmail == (Auth.auth().currentUser?.email)! {
            self.trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped))
            self.navigationItem.rightBarButtonItem = self.trash
        }
       
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
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func pinchAction(sender: UIPinchGestureRecognizer) {
        if previousScale * sender.scale >= 0.8 && previousScale * sender.scale <= 4.0 {
            let scale:CGFloat = previousScale * sender.scale
            self.view.transform = CGAffineTransform(scaleX: scale, y: scale);
            previousScale = sender.scale
        }
    }
    
    @objc func swipeAction(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            let labelPosition = CGPoint(x: self.view.frame.origin.x - 100.0, y: self.view.frame.origin.y)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            })
        }
        else if (sender.direction == .right) {
            let labelPosition = CGPoint(x: self.view.frame.origin.x + 100.0, y: self.view.frame.origin.y)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            })
        }
        else if (sender.direction == .up) {
            let labelPosition = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.origin.y - 100.0)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            })
        }
        else if (sender.direction == .down) {
            let labelPosition = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.origin.y + 100.0)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            })
        }
    }

}
