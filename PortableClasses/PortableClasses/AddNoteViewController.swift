//
//  AddNoteViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/3/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit

class AddNoteViewController: UIViewController {
    
    var callback : ((String) -> Void)?

    @IBOutlet weak var noteBody: UITextView!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelAddingNote(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNoteTapped(_ sender: Any) {
        callback?(noteBody.text!)
        self.dismiss(animated: true, completion: nil)
    }

}
