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
        
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white//(red:0.13, green:0.03, blue:0.59, alpha:1.0)
        
        let backButton = UIBarButtonItem()
        backButton.title = "Notes"
        backButton.tintColor = UIColor(red:0.13, green:0.03, blue:0.59, alpha:1.0)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

    }
    
    @IBAction func addNoteTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
