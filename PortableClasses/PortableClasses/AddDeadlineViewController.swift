//
//  AddDeadlineViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 5/2/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import EventKit

class AddDeadlineViewController: UIViewController {

    var callback1 : ((String) -> Void)?
    var callback2 : ((String) -> Void)?
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var reminderTextField: UITextField!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var dateToAdd:String!
    var dateFormatterForCal = DateFormatter()
    
    
    var datePicker: UIDatePicker?
    var newDeadline: String?
    var newDate: String?
    var addToCalendar:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // create date picker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .dateAndTime
        
        // add toolbar to date picker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed(_:)))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed(_:)))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbar.setItems([cancelButton, flexButton, doneButton], animated: false)
        dateTextField.inputView = datePicker
        dateTextField?.inputAccessoryView = toolbar
    }
    
    @objc func cancelPressed(_ sender: UIBarButtonItem) {
        view.endEditing(true)
    }
    
    @objc func donePressed(_ sender: UIBarButtonItem) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE MMM dd, yyyy 'at' HH:mm "
        dateTextField.text = dateFormatter.string(from: (datePicker?.date)!)
        view.endEditing(true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }
 
    
    
    @IBAction func cancelAddingDeadline(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addDeadlineTapped(_ sender: Any) {
        
//        let deadlinesVC = segue.destination as! DeadlinesTableViewController
//        deadlinesVC.deadlines.append(newDeadline)
        
        callback1?(reminderTextField.text!)
        callback2?(dateTextField.text!)
        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
        
        
        
        // add to calendar
        if addToCalendar {
            let eventStore:EKEventStore = EKEventStore()
            
            eventStore.requestAccess(to: .event, completion: {(granted, error) in
                if granted && error == nil {
                    
                    let event:EKEvent = EKEvent(eventStore: eventStore)
                    event.title = self.reminderTextField.text
                    event.startDate = Date()
                    print(event.startDate)
                    event.endDate = Date()
                    event.notes = "Optional Notes"
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        try eventStore.save(event, span: .thisEvent)
                    }
                    catch let error as NSError{
                        print("err")
                    }
                }
                else {
                    print("err")
                }
                
            })
        }
    }
    
    
    @IBAction func calSwitch(_ sender: UISwitch) {
        if sender.isOn {
            addToCalendar = true
        }
        else {
            addToCalendar = false
        }
    }
    
}
