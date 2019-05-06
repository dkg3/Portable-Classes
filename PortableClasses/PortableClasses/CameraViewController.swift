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

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var myImg: UIImageView!
    
    var allImages: [String] = []
    
    var currSemester = ""
    var currClass = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func importImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            myImg.image = pickedImage
            
            var data = Data()
            data = pickedImage.jpegData(compressionQuality: 0.8)!
            let imageRef = Storage.storage().reference().child((Auth.auth().currentUser?.email)! + "/" +  randomString(20))
            _ = imageRef.putData(data, metadata: nil) { (metadata, error) in
                imageRef.downloadURL { url, error in
                    if error != nil {

                    } else {
                        self.allImages.append(url?.absoluteString ?? "")
                        let db = Firestore.firestore()
                        let allUsersRef: CollectionReference? = db.collection("users")
                        let currUserRef: DocumentReference? = allUsersRef?.document((Auth.auth().currentUser?.email)!).collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("handNotes")
                        currUserRef?.setData([
                            "handNotes": FieldValue.arrayUnion([url?.absoluteString ?? ""])
                        ], merge: true) { err in
                            if err != nil {
                                print("Error adding document")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func randomString(_ length: Int) -> String {
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
    
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
