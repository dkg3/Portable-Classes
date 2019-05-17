//
//  AddNoteViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/3/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import AVFoundation

class AddNoteViewController: UIViewController, UITextViewDelegate {
    
    // callback variable to pass the created note to the notes script
    var callback : ((String) -> Bool)?

    // variable for the text view where the note text is displayed
    @IBOutlet weak var noteBody: UITextView!
    
    // variables to cancel out of the view or add a note
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // initial variable for sound
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // display the keyboard right away with a toolbar item that says done
        // used to dismiss the keyboard
        noteBody.delegate = self
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(stopEditing(_:)))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.setItems([flexButton, flexButton, doneButton], animated: false)
        // style the toolbar
        noteBody?.inputAccessoryView = toolbar
        noteBody.textColor = UIColor(red:0.13, green:0.03, blue:0.59, alpha:1.0)
        noteBody.font = UIFont(name: "Avenir-Medium", size: 20)
        noteBody.becomeFirstResponder()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        // add button is initially disabled until text is added
        addButton.isEnabled = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // toggle add button upon text being added/removed
        addButton.isEnabled = textView.text!.count > 0
    }
    
    @objc func stopEditing(_ sender: UIBarButtonItem) {
        // dismiss the keyboard
        view.endEditing(true)
    }
    
    @IBAction func cancelAddingNote(_ sender: Any) {
        // dismiss the view controller
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNoteTapped(_ sender: Any) {
        // send the note text to notes view controller through the callback
        if (callback?(noteBody.text!))! {
            // play the add sound when the note is successfully added
            let path = Bundle.main.path(forResource: "add", ofType:"mp3")!
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
            } catch {
                
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // tap the screen to dismiss the keyboard
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // change the status bar style to black when entering the view
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // change the status bar style to light when leaving the view
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }

}
