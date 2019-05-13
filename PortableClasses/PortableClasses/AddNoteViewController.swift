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
    
    var callback : ((String) -> Bool)?

    @IBOutlet weak var noteBody: UITextView!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteBody.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(stopEditing(_:)))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.setItems([flexButton, flexButton, doneButton], animated: false)
        noteBody?.inputAccessoryView = toolbar
        
        noteBody.textColor = UIColor(red:0.13, green:0.03, blue:0.59, alpha:1.0)
        noteBody.font = UIFont(name: "Avenir-Medium", size: 20)
        noteBody.becomeFirstResponder()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        addButton.isEnabled = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // toggle add button upon text being added/removed
        addButton.isEnabled = textView.text!.count > 0
    }
    
    @objc func stopEditing(_ sender: UIBarButtonItem) {
        view.endEditing(true)
    }
    
    @IBAction func cancelAddingNote(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNoteTapped(_ sender: Any) {
        if (callback?(noteBody.text!))! {
            let path = Bundle.main.path(forResource: "add", ofType:"mp3")!
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
            } catch {
                print("uh oh")
            }
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }

}
