//
//  CameraViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 4/29/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import AVFoundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {

    // variable for the image to be added
    @IBOutlet weak var myImg: UIImageView!
    
    // callback variable to pass the image to the pictures script
    var callback : ((UIImageView) -> Void)?
    
    // array of images
    var allImages: [String] = []
    // variable to the current semester and class
    var currSemester = ""
    var currClass = ""
    
    // initial variable for sound
    var audioPlayer = AVAudioPlayer()
    
    // variable for done button when finished adding an image
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // disable the done button until a picture has been chosen
        doneButton.isEnabled = false
    }
    
    @IBAction func importImage(_ sender: Any) {
        // import an image through the photo library of the phone
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        // if the app has access to the phone's camera
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            // take a picture using the phone
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // dismiss the image picker once an image has been selected
        picker.dismiss(animated: true, completion: nil)
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // assign the picked image to the image view
            myImg.image = pickedImage
            // enable the done button
            doneButton.isEnabled = true
        }
    }
    
    func randomString(_ length: Int) -> String {
        // create a random unique string to identify each image
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    @IBAction func cancelView(_ sender: Any) {
        // if cancel is pressed, dismiss the view without adding an image
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneView(_ sender: Any) {
        // if an image has been added
        if myImg.image != nil {
            // play the success sound when adding an image
            let path = Bundle.main.path(forResource: "add", ofType:"mp3")!
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
            } catch {
                
            }
            // compress the image for faster load time
            var data = Data()
            data = myImg.image!.jpegData(compressionQuality: 0.3)!
            // add the image to firebase storage
            let imageRef = Storage.storage().reference().child((Auth.auth().currentUser?.email)! + "/" +  randomString(20))
            // download the storage url
            _ = imageRef.putData(data, metadata: nil) { (metadata, error) in
                imageRef.downloadURL { url, error in
                    if error != nil {}
                    else {
                        // add the url to the array of images
                        self.allImages.append(url?.absoluteString ?? "")
                        // get reference to firebase
                        let db = Firestore.firestore()
                        // reference to all the users
                        let allUsersRef: CollectionReference? = db.collection("users")
                        // reference to the document of handNotes
                        let currUserRef: DocumentReference? = allUsersRef?.document((Auth.auth().currentUser?.email)!).collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("handNotes")
                        // add the image to the database
                        currUserRef?.setData([
                            "handNotes": FieldValue.arrayUnion([url?.absoluteString ?? ""])
                        ], merge: true) { err in
                            if err != nil {}
                            else {
                                // send the image through the callback
                                self.callback?(self.myImg)
                            }
                        }
                    }
                }
            }
        }
        // dismiss the view controller
        self.dismiss(animated: true, completion: nil)
    }
    
}
