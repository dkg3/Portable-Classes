//
//  AddDeadlineViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 5/2/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import EventKit
import AVFoundation

class AddDeadlineViewController: UIViewController {

    // callback variable to pass the reminder event and date back to deadlines script
    var callback1 : ((String, String) -> Bool)?
    
    // reminder event and date text field variables
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var reminderTextField: UITextField!
    
    // cancel and add button variables
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // flags to know if fields have values in them
    var reminderDone: Bool! = false
    var dateDone: Bool! = false
    
    // variables for the date field
    var dateToAdd:Date?
    var dateFormatterForCal = DateFormatter()
    var datePicker: UIDatePicker?
    var newDeadline: String?
    var newDate: String?
    
    // flag to know whether to add the event to iOS calendar or not
    var addToCalendar:Bool = false
    
    // initial variable for sound
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // create date picker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .dateAndTime
        
        // add toolbar to date picker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // create cancel and done buttons that have associated functions to perform when pressed
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed(_:)))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed(_:)))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.setItems([cancelButton, flexButton, doneButton], animated: false)
        
        // add the date picker to the text field so it appears when clicked
        dateTextField.inputView = datePicker
        dateTextField?.inputAccessoryView = toolbar
        
        // call handleTap function to process a user tap on the screen
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        // add button is initially disabled until text fields have been filled
        addButton.isEnabled = false
        
        // associate a function to the text fields to perform an action when the field is updated
        reminderTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        dateTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingDidEnd)
        
        // have the keyboard appear and ready to type in reminder field upon entering the view
        reminderTextField.becomeFirstResponder()
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        // toggle add button when both text fields are filled
        if textField == reminderTextField {
            addButton.isEnabled = textField.text!.count > 0 && dateTextField.text!.count > 0
        }
        else {
            addButton.isEnabled = textField.text!.count > 0 && reminderTextField.text!.count > 0
        }
    }
    
    @objc func cancelPressed(_ sender: UIBarButtonItem) {
        // remove the date picker when cancel is pressed
        view.endEditing(true)
    }
    
    @objc func donePressed(_ sender: UIBarButtonItem) {
        // remove the date picker and add the date and time
        // picked to the date text field when done is pressed
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE MMM dd, yyyy 'at' HH:mm "
        dateToAdd = self.datePicker!.date
        dateTextField.text = dateFormatter.string(from: (datePicker?.date)!)
        view.endEditing(true)
    }
    
    @IBAction func cancelAddingDeadline(_ sender: Any) {
        // exit the view controller
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addDeadlineTapped(_ sender: Any) {
        // pass the reminder and date text fields in the callback
        if (callback1?(reminderTextField.text!, dateTextField.text!))! {
            // play the add deadline sound if the deadline was successfully added
            let path = Bundle.main.path(forResource: "add", ofType:"mp3")!
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
            } catch {
                
            }
            
            // add to iOS calendar
            if addToCalendar {
                let eventStore:EKEventStore = EKEventStore()
                eventStore.requestAccess(to: .event, completion: {(granted, error) in
                    if granted && error == nil {
                        let event:EKEvent = EKEvent(eventStore: eventStore)
                        event.title = self.reminderTextField.text
                        event.startDate = self.dateToAdd
                        event.endDate = self.dateToAdd
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        do {
                            try eventStore.save(event, span: .thisEvent)
                        }
                        catch _ as NSError{
                            
                        }
                    }
                })
            }
            // dismiss the view controller upon adding a deadline successfully
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func calSwitch(_ sender: UISwitch) {
        // toggle add to calendar flag based on if the switch is on or off
        if sender.isOn {
            addToCalendar = true
        }
        else {
            addToCalendar = false
        }
        // play the flip sound every time the switch is toggled
        let path = Bundle.main.path(forResource: "flip", ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // remove the keyboard and stop editing the text field previously in
        view.endEditing(true)
    }
    
}
