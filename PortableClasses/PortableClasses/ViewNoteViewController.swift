//
//  ViewNoteViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/3/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit

class ViewNoteViewController: UIViewController, UITextViewDelegate {
    
    var currNote = ""
    
    var edit: UIBarButtonItem!
    var done: UIBarButtonItem!
    
    var callback : ((String) -> Void)?

    @IBOutlet weak var completedNoteText: UITextView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        completedNoteText.delegate = self
        completedNoteText.text = currNote
        
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        let backButton = UIBarButtonItem()
        backButton.title = "Notes"
        backButton.tintColor = UIColor(red:0.13, green:0.03, blue:0.59, alpha:1.0)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        self.edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editNote))
        
        done.tintColor = UIColor(red:0.13, green:0.03, blue:0.59, alpha:1.0)
        self.edit.tintColor = UIColor(red:0.13, green:0.03, blue:0.59, alpha:1.0)
        
        self.navigationItem.rightBarButtonItem = self.edit
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red:0.13, green:0.03, blue:0.59, alpha:1.0)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // toggle add button upon text being added/removed
        self.done.isEnabled = textView.text!.count > 0
    }
    
    @objc func editNote(_ sender: Any) {
        completedNoteText.isEditable = true
        completedNoteText.becomeFirstResponder()
        self.navigationItem.rightBarButtonItem = self.done
    }
    
    @objc func doneTapped(_ sender: Any) {
        completedNoteText.isEditable = false
        view.endEditing(true)
        self.navigationItem.rightBarButtonItem = self.edit
        callback?(completedNoteText.text!)
    }
}
