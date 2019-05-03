//
//  ViewNoteViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/3/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit

class ViewNoteViewController: UIViewController {
    
    var currNote = ""

    @IBOutlet weak var completedNoteText: UITextView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        completedNoteText.text = currNote
    }
    
    @IBAction func addNoteTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
