//
//  DetailViewController.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 31/08/25.
//

import UIKit
import RealmSwift

protocol DetailViewControllerDelegate: AnyObject {
    func didAddBirthday(_ item: Item)
}

class DetailViewController: UIViewController {
    
    weak var delegate : DetailViewControllerDelegate?
    //var selectedCategory: Category?
    var category : Category?
    
    let newItem = Item()
    
    var items : Results<Item>?
    
    let realm = try! Realm()

    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var dateAndTimePicker: UIDatePicker!
    
    @IBOutlet weak var plansField: UITextField!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var repeatYearly: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        do {
            try realm.write {
                switch segmentedControl.selectedSegmentIndex {
                //exact time
                case 0:
                    newItem.remind = 0
                    newItem.customRemindDate = nil
                //1 day before
                case 1:
                    newItem.remind = -86400
                    newItem.customRemindDate = nil
                //1 weeek before
                case 2:
                    newItem.remind = -604800
                    newItem.customRemindDate = nil
                //1 month before
                case 3:
                    newItem.remind = -2592000
                    newItem.customRemindDate = nil
                case 4:
                    showDateTimePicker(for: newItem)
                    
                default: break
                }
            }
        } catch {
            print("Error saving reminder option: \(error)")
        }
        segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
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
//            let formatter = DateFormatter()
//            formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
//            let selectedDate = formatter.string(from: datePicker.date)
//            print("selected DateTime: \(selectedDate)")
//            
//            currentItem.customRemindDate = datePicker.date
            let selectedDate = datePicker.date
                print("Selected custom reminder date:", selectedDate)
                
                do {
                    try self.realm.write {
                        item.customRemindDate = selectedDate
                        item.remind = 0
                    }
                } catch {
                    print("Error saving custom date: \(error)")
                }
        }))
        
        // Add Cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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

        if let category = category {
            do {
                try realm.write {
                    category.items.append(newItem)
                }
                delegate?.didAddBirthday(newItem)
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


