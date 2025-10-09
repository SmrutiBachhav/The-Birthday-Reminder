//
//  EditViewController.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 05/09/25.
//
import UIKit
import RealmSwift
import ChameleonFramework

class ShowViewController: UIViewController {
 
    weak var delegate : AddViewControllerDelegate?
    //var selectedCategory: Category?
    var category : Category?
        
    var itemToShow: Item?
    
    var items : Results<Item>?
    
    let realm = try! Realm()

    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var dateAndTime: UILabel!
    
    @IBOutlet weak var plans: UILabel!
    
    @IBOutlet weak var remindBefore: UILabel!

    @IBOutlet weak var repeatYearly: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupItemDisplay()
        updateUIColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupItemDisplay() //refresh display when returning from edit
        updateUIColors()
    }
    
    func setupItemDisplay() {
        guard let item = itemToShow else {
            clearDisplay()
            return
        }
        
        name.text = item.name
        dateAndTime.text = dateAndTimeFormat((itemToShow?.date)!)
        plans.text = item.plan
        
        setReminderText(for: item)
        
        repeatYearly.isOn = (item.repeatYearly)
    
    }
    
    func clearDisplay() {
        name.text = "No Item"
        dateAndTime.text = "No Date"
        plans.text = "No Plans"
        remindBefore.text = "No Reminder"
        repeatYearly.isOn = false
    }
    
    func setReminderText(for item: Item) {
        switch item.remind {
        case 0:
            if let customeDateTime = item.customRemindDate {
                remindBefore.text = dateAndTimeFormat(customeDateTime)
            } else {
                remindBefore.text = "Exact time"
            }
        case -86400:
            remindBefore.text = "1 day before."
        case -604800:
            remindBefore.text = "1 week before."
        case -2592000:
            remindBefore.text = "1 month before."
        default:
            remindBefore.text = "No Reminder set"
        }
    }

//    to show custome date and time saved for reminder
//    func showCustomDateTime() {
//        if let dateFormat = itemToShow?.customRemindDate {
//            remindBefore.text = dateAndTimeFormat(dateFormat)
//        }
//    }
        
    func dateAndTimeFormat(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        return formatter.string(from: date)
    }

    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editItem" {
            if let destinationVC = segue.destination as? AddViewController {
                destinationVC.itemToEdit = itemToShow
                destinationVC.delegate = self
                destinationVC.category = category
            }
        }
    }
}

extension ShowViewController : AddViewControllerDelegate {
    //to update show details
    func didUpdateBirthday(_ item: Item) {
        //Refresh UI with Updated data
        itemToShow = item
        setupItemDisplay()
        
        // Update the list view controller if it exists in navigation stack
        if let navigationController = self.navigationController,
            let listVC = navigationController.viewControllers.first(where: { $0 is BirthdayReminderViewController}) as? BirthdayReminderViewController {
            listVC.didUpdateItemInBdyList(item)
        }
    }
    
    //to update bdyList
    func didUpdateItemInBdyList(_ item: Item) {
        itemToShow = item
        setupItemDisplay()
    }

}


//MARK: - UI Color Update
extension ShowViewController {
    func updateUIColors() {
        guard let category = self.category,
              let categoryColor = UIColor(hexString: category.color) else { return }
        
        // Update navigation bar
        updateNavigationBar(with: categoryColor)
     // Update view background with gradient or solid color
        //view.backgroundColor = categoryColor.lighten(byPercentage: 0.25)
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: view.bounds, andColors: [categoryColor.lighten(byPercentage: 0.25) ?? categoryColor, categoryColor.darken(byPercentage: 0.75) ?? categoryColor])
        view.tintColor = ContrastColorOf(categoryColor, returnFlat: true)
        // Update navigation bar icons (back button, edit button)
        //updateNavigationBarIcons(with: categoryColor)
        }
        
        private func updateNavigationBar(with color: UIColor) {
            guard let navBar = navigationController?.navigationBar else { return }
            
            navBar.backgroundColor = color
            navBar.tintColor = ContrastColorOf(color, returnFlat: true)
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
        }
        
        private func updateNavigationBarIcons(with color: UIColor) {
            // The navigation bar tint color will handle back button and bar button items
            navigationController?.navigationBar.tintColor = ContrastColorOf(color, returnFlat: true)
        
        }
}
