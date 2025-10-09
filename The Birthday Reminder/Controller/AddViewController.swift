//
//  DetailViewController.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 31/08/25.
//

import UIKit
import RealmSwift
import UserNotifications
import ChameleonFramework

protocol AddViewControllerDelegate: AnyObject {
    //to update show details
    func didUpdateBirthday(_ item: Item)
    //to update list
    func didUpdateItemInBdyList(_ item: Item)
}

class AddViewController: UIViewController {
        
    weak var delegate : AddViewControllerDelegate?
    var category : Category?
    var itemToEdit: Item?
    
    
    //let newItem = Item()
    // Store data as simple properties instead of Realm object
    var itemName: String = ""
    var itemDate: Date = Date()
    var itemPlan: String = ""
    var itemRemind: Double = 0
    var itemCustomRemindDate: Date?
    var itemRepeatYearly: Bool = false
    
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
        updateUIColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            updateUIColors()
    }
    
    func setupUI() {
        if let item = itemToEdit {
            nameField.text = item.name
            dateAndTimePicker.date = item.date
            plansField.text = item.plan
            itemName = item.name
            itemDate = item.date
            itemPlan = item.plan
            itemRemind = item.remind
            itemCustomRemindDate = item.customRemindDate
            itemRepeatYearly = item.repeatYearly
            
            switch item.remind {
            case 0:
                if item.customRemindDate != nil {
                    segmentedControl.selectedSegmentIndex = 4
                    customRemindDate = item.customRemindDate!
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
    
    // MARK: - UI Color Updates
    func updateUIColors() {
        guard let category = self.category,
              let categoryColor = UIColor(hexString: category.color) else { return }
        
        // Update navigation bar
        updateNavigationBar(with: categoryColor)
        
        // Update view background
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: view.bounds, andColors: [categoryColor.lighten(byPercentage: 0.25) ?? categoryColor, categoryColor.darken(byPercentage: 0.75) ?? categoryColor])
        
        // Update UI controls colors
        updateControlColors(with: categoryColor)
    }
    private func updateNavigationBar(with color: UIColor) {
            guard let navBar = navigationController?.navigationBar else { return }
            
            navBar.backgroundColor = color
            navBar.tintColor = ContrastColorOf(color, returnFlat: true)
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
        }
        
        private func updateControlColors(with color: UIColor) {
            // Update segmented control
            segmentedControl.backgroundColor = color.lighten(byPercentage: 0.8)
            segmentedControl.selectedSegmentTintColor = color
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)], for: .selected)
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: color], for: .normal)
            
            // Update switch
            repeatYearly.onTintColor = color
            
            // Update date picker (if possible)
//            if #available(iOS 14.0, *) {
//                dateAndTimePicker.preferredDatePickerStyle = .automatic
            dateAndTimePicker.tintColor = color.lighten(byPercentage: 0.5)
//            }
            
            // Update text fields
            nameField.tintColor = color.lighten(byPercentage: 0.50)
            plansField.tintColor = color.lighten(byPercentage: 0.50)
            
            // Add subtle borders to text fields
            styleTextField(nameField, with: color)
            styleTextField(plansField, with: color)
        }
        
        private func styleTextField(_ textField: UITextField, with color: UIColor) {
//            textField.layer.borderColor = color.cgColor
//            textField.layer.borderWidth = 1.0
//            textField.layer.cornerRadius = 8.0
            textField.backgroundColor = color
            
            // Add padding to text field
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
            textField.leftView = paddingView
            textField.leftViewMode = .always
        }

    
    

    //MARK: - Segmented Control Action to set reminder
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
            showDateTimePicker()
        default: break
        }
    }
    
    func showDateTimePicker(){
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
        itemRepeatYearly = sender.isOn
        //        do {
        //            try realm.write {
        //                newItem.repeatYearly = sender.isOn
        //            }
        //        } catch {
        //            print("Error saving repeat yearly: \(error)")
        //        }
    }
    
    @IBAction func nameField(_ sender: UITextField) {
        itemName = nameField.text ?? ""
        //        if let name = nameField.text {
        //            do {
        //                try realm.write {
        //                    newItem.name = name
        //                }
        //            } catch {
        //                print("Error saving name: \(error)")
        //            }
        //        }
    }
    
    @IBAction func plansField(_ sender: UITextField) {
        itemPlan = plansField.text ?? ""
        //        if let plans = plansField.text {
        //            do {
        //                try realm.write {
        //                    newItem.plan = plans
        //                }
        //            } catch {
        //                print("Error saving plan \(error)")
        //            }
        //        }
    }
    
    //MARK: - Data Manipulation
    func updateReminder(remind: Double, customDate: Date?) {
        do {
            try realm.write {
                itemRemind = remind
                itemCustomRemindDate = customDate
                if customDate != nil {
                    customRemindDate = customDate!
                }
            }
        } catch {
            print("Error saving reminder: \(error)")
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        itemName = nameField.text ?? ""
        itemDate = dateAndTimePicker.date
        itemPlan = plansField.text ?? ""
        itemRepeatYearly = repeatYearly.isOn
        
        if nameField.text == "" || segmentedControl == nil {
            let alert = UIAlertController(title: "Error", message: "Please enter details for your reminder.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //Editing existing item
        if let item = itemToEdit {
            do {
                try realm.write {
                    item.name = itemName
                    item.date = itemDate
                    item.plan = itemPlan
                    item.repeatYearly = itemRepeatYearly
                    switch segmentedControl.selectedSegmentIndex {
                    case 0:
                        item.remind = 0
                        item.customRemindDate = nil
                    case 1:
                        item.remind = -86400
                        item.customRemindDate = nil
                    case 2:
                        item.remind = -604800
                        item.customRemindDate = nil
                    case 3:
                        item.remind = -2592000
                        item.customRemindDate = nil
                    case 4:
                        item.remind = 0
                        item.customRemindDate = customRemindDate
                    default:
                        item.remind = 0
                        item.customRemindDate = nil
                    }
                }
                NotificationManager.shared.requestNotificationPermissionIfNeeded(for: item.name, on: item.date, doRepeat: item.repeatYearly, from: self)
                //Sceheduled Notification for existing item
//                NotificationManager.shared.scheduleReminder(for: item.name, on: item.date, doRepeat: item.repeatYearly)
                
                delegate?.didUpdateBirthday(item)
                navigationController?.popViewController(animated: true)
            } catch {
                print("Error Editing Data: \(error)")
            }
        } else if let category = category {     //Adding new Category
            let newItem = Item()
            do {
                try realm.write {
                    newItem.name = itemName
                    newItem.date = itemDate
                    newItem.plan = itemPlan
                    newItem.repeatYearly = itemRepeatYearly
                    switch segmentedControl.selectedSegmentIndex {
                    case 0:
                        newItem.remind = 0
                        newItem.customRemindDate = nil
                    case 1:
                        newItem.remind = -86400
                        newItem.customRemindDate = nil
                    case 2:
                        newItem.remind = -604800
                        newItem.customRemindDate = nil
                    case 3:
                        newItem.remind = -2592000
                        newItem.customRemindDate = nil
                    case 4:
                        newItem.remind = 0
                        newItem.customRemindDate = customRemindDate
                    default:
                        newItem.remind = 0
                        newItem.customRemindDate = nil
                    }
                    category.items.append(newItem)
                }
                
                NotificationManager.shared.requestNotificationPermissionIfNeeded(for: newItem.name, on: newItem.date, doRepeat: newItem.repeatYearly, from: self)
                
                //Sceheduled Notification for existing item
//                NotificationManager.shared.scheduleReminder(for: newItem.name, on: newItem.date, doRepeat: newItem.repeatYearly)
                
                delegate?.didUpdateBirthday(newItem)
                navigationController?.popViewController(animated: true)
            } catch {
                print("Error saving new item: \(error)")
            }
        }
    }
}


