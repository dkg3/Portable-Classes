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

    @IBOutlet weak var termTextField: UITextField!
    @IBOutlet weak var defintionTextView: UITextView!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var callback1: ((String, String) -> Bool)?
    var callback2: ((String) -> Void)?
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defintionTextView.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        termTextField.becomeFirstResponder()
        
        addButton.isEnabled = false
        termTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        // toggle add button when both text fields are filled
        addButton.isEnabled = textField.text!.count > 0 && defintionTextView.text!.count > 0
    }
    
    func textViewDidChange(_ textView: UITextView) {
        addButton.isEnabled = textView.text!.count > 0 && termTextField.text!.count > 0
    }
    
    
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        if (callback1?(termTextField.text!, defintionTextView.text!))! {
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
//        callback2?(defintionTextView.text!)
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}
