//
//  AddFlashCardViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 5/5/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import AVFoundation

class AddFlashCardViewController: UIViewController, UITextViewDelegate {

    // variables for term and definition fields
    @IBOutlet weak var termTextField: UITextField!
    @IBOutlet weak var defintionTextView: UITextView!
    
    // variables to the cancel and add buttons
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // callback variable to pass the term and definition back to the flashcard script
    var callback1: ((String, String) -> Bool)?
    
    // initial variable for sound
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defintionTextView.delegate = self
        // add a tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        // have the keyboard appear initially so term field can be edited
        termTextField.becomeFirstResponder()
        // add button enabled until term and definition have text in them
        addButton.isEnabled = false
        termTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        // toggle add button when both text fields are filled
        addButton.isEnabled = textField.text!.count > 0 && defintionTextView.text!.count > 0
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // toggle add button when both text fields are filled
        addButton.isEnabled = textView.text!.count > 0 && termTextField.text!.count > 0
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        // dismiss the view controller
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        // send the term and definition to the callback function
        if (callback1?(termTextField.text!, defintionTextView.text!))! {
            // play the success sound when a flashcard is added
            let path = Bundle.main.path(forResource: "add", ofType:"mp3")!
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
            } catch {
                
            }
            // dismiss the view controller
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // dismiss the keyboard
        view.endEditing(true)
    }
    
}
