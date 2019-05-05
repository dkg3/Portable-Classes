//
//  FlashcardSingleViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 5/4/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit

class NONEEDFlashcardSingleViewController: UIViewController {

    @IBOutlet private weak var textLabel: UILabel!
    
    var text: String?
    var bgColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        if let text = text {
//            let pStyle = NSMutableParagraphStyle()
//            pStyle.alignment = .center
//            textLabel.attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: pStyle])
////            textLabel.text =
//        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let text = text {
            textLabel.text = text
        }
        
        if let bgColor = bgColor {
            view.backgroundColor = bgColor
            
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
