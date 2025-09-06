//
//  DetailViewController.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 31/08/25.
//

import UIKit
import RealmSwift

protocol AddViewControllerDelegate: AnyObject {
    //to update show details
    func didUpdateBirthday(_ item: Item)
    //to update list
    func didUpdateItemInBdyList(_ item: Item)
}

class AddViewController: UIViewController {
    
    weak var delegate : AddViewControllerDelegate?
    //var selectedCategory: Category?
    var category : Category?
    
    var itemToEdit: Item?
    
    let newItem = Item()
    
    var items : Results<Item>?
    var customRemindDate : Date = Date()
    let realm = try! Realm()

    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var dateAndTimePicker: UIDatePicker!
    
    @IBOutlet weak var plansField: UITextField!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var repeatYearly: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        
    }
    
    func setupUI() {
        if let item = itemToEdit {
            nameField.text = item.name
            dateAndTimePicker.date = item.date
            plansField.text = item.plan
            switch item.remind {
            case 0:
                if item.customRemindDate != nil {
                    segmentedControl.selectedSegmentIndex = 4
                    customRemindDate = item.customRemindDate!
                    //showDateTimePicker(for: item)
                } else {
                    segmentedControl.selectedSegmentIndex = 0
                }
            case -86400:
                segmentedControl.selectedSegmentIndex = 1
            case -604800:
                segmentedControl.selectedSegmentIndex = 2
            case -2592000:
                segmentedControl.selectedSegmentIndex = 3
            default:
                segmentedControl.selectedSegmentIndex = 0
            }
            repeatYearly.isOn = item.repeatYearly
        }
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {

        switch segmentedControl.selectedSegmentIndex {
        //exact time
        case 0:
            updateReminder(remind: 0, customDate: nil)
        //1 day before
        case 1:
            updateReminder(remind: -86400, customDate: nil)

        //1 weeek before
        case 2:
            updateReminder(remind: -604800, customDate: nil)
        //1 month before
        case 3:
            updateReminder(remind: -2592000, customDate: nil)
        case 4:
            showDateTimePicker(for: newItem)
        default: break
        }
    }
    
    func updateReminder(remind: Double, customDate: Date?) {
        do {
            try realm.write {
                newItem.remind = remind
                newItem.customRemindDate = customDate
                if customDate != nil {
                    customRemindDate = customDate!
                }
            }
        } catch {
            print("Error saving reminder: \(error)")
        }
    }
    
    func showDateTimePicker(for item: Item){
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        
        //add datePicker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .inline
        //datePicker.frame = CGRect(x: 0, y: 0, width: alert.view.bounds.size.width - 20, height: 250)
        //autolayout intstead of frame
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        alert.view.addSubview(datePicker)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            let selectedDate = datePicker.date
            print("Selected custom reminder date:", selectedDate)
            self.customRemindDate = selectedDate
            self.updateReminder(remind: 0, customDate: selectedDate)
//          item.remind = 0
//          item.customRemindDate = self.customRemindDate
            print(self.customRemindDate)
                    
        }))
        
        // Add Cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in 
            if self.itemToEdit?.customRemindDate != nil {
                self.segmentedControl.selectedSegmentIndex = 0
            }
        }))
        alert.view.heightAnchor.constraint(equalToConstant: 500).isActive = true

        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func repeatYearly(_ sender: UISwitch) {
        do {
            try realm.write {
                newItem.repeatYearly = sender.isOn
            }
        } catch {
            print("Error saving repeat yearly: \(error)")
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
            newItem.name = nameField.text ?? ""
            newItem.date = dateAndTimePicker.date
            newItem.plan = plansField.text ?? ""
            newItem.repeatYearly = repeatYearly.isOn

        if nameField.text == "" || segmentedControl == nil {
            let alert = UIAlertController(title: "Error", message: "Please enter details for your reminder.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        //Editing existing item
        if let item = itemToEdit {
            do {
                try realm.write {
                    item.name = nameField.text ?? ""
                    item.date = dateAndTimePicker.date
                    item.plan = plansField.text ?? ""
                    item.repeatYearly = repeatYearly.isOn
                    //item.remind = Double(segmentedControl.selectedSegmentIndex)
                    item.remind = Double(segmentedControl.selectedSegmentIndex)
                    switch segmentedControl.selectedSegmentIndex {
                    case 0:
                        item.remind = 0
                        item.customRemindDate = nil
                    case 1:
                        item.remind = -86400
                        item.customRemindDate = nil
                    case 2:
                        item.remind = -604800
                    case 3:
                        item.remind = -2592000
                    case 4:
                        item.remind = 0
                        item.customRemindDate = customRemindDate
                    default:
                        item.remind = 0
                        item.customRemindDate = nil
                    }
                }
                delegate?.didUpdateBirthday(item)
                //delegate?.didUpdateItemInBdyList(item)
                navigationController?.popViewController(animated: true)
            } catch {
                print("Error Editing Data: \(error)")
            }
        } else if let category = category {     //Adding new Category
            do {
                try realm.write {
                    category.items.append(newItem)
                }
                delegate?.didUpdateBirthday(newItem)
                //delegate?.didUpdateItemInBdyList(newItem)
                navigationController?.popViewController(animated: true)
            } catch {
                print("Error saving new item: \(error)")
            }
        }
    }
  
    @IBAction func nameField(_ sender: UITextField) {
        if let name = nameField.text {
            do {
                try realm.write {
                    newItem.name = name
                }
            } catch {
                print("Error saving name: \(error)")
            }
        }
    }
    
    @IBAction func plansField(_ sender: UITextField) {
        if let plans = plansField.text {
            do {
                try realm.write {
                    newItem.plan = plans
                }
            } catch {
                print("Error saving plan \(error)")
            }
        }
    }
}


