//
//  ViewNoteViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/3/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class ViewNoteViewController: UIViewController, UITextViewDelegate {
    
    // user from map table, not the logged in user
    var userEmail: String!
    // the current note selected
    var currNote = ""
    
    // edit and done button variables that we will use to toggle
    var edit: UIBarButtonItem!
    var done: UIBarButtonItem!
    
    // callback variable to pass the edited note to the notes script
    var callback : ((String) -> Void)?

    // variables for the text view where the note is written and the edit button
    @IBOutlet weak var completedNoteText: UITextView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set the text to the selected note
        completedNoteText.delegate = self
        completedNoteText.text = currNote
        // style the nav bar
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        let backButton = UIBarButtonItem()
        backButton.title = "Notes"
        backButton.tintColor = UIColor(red:0.13, green:0.03, blue:0.59, alpha:1.0)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        // only allow user to edit their own content
        if userEmail == (Auth.auth().currentUser?.email)! {
            // create the edit and done buttons, start by displaying edit
            self.done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
            self.edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editNote))
            done.tintColor = UIColor(red:0.13, green:0.03, blue:0.59, alpha:1.0)
            self.edit.tintColor = UIColor(red:0.13, green:0.03, blue:0.59, alpha:1.0)
            self.navigationItem.rightBarButtonItem = self.edit
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red:0.13, green:0.03, blue:0.59, alpha:1.0)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // change the status bar style to black when entering the view
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // change the status bar style to white when leaving the view
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // toggle add button upon text being added/removed
        self.done.isEnabled = textView.text!.count > 0
    }
    
    @objc func editNote(_ sender: Any) {
        // can edit text once edit is pressed
        completedNoteText.isEditable = true
        // keyboard pops up
        completedNoteText.becomeFirstResponder()
        // the right bar button now says Done
        self.navigationItem.rightBarButtonItem = self.done
    }
    
    @objc func doneTapped(_ sender: Any) {
        // editing has finished
        completedNoteText.isEditable = false
        // dismiss the keyboard
        view.endEditing(true)
        // the right bar buttin now says Edit
        self.navigationItem.rightBarButtonItem = self.edit
        // send the updated note back to the notes view controller
        callback?(completedNoteText.text!)
    }
    
}
