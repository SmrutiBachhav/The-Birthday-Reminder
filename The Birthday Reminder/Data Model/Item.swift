//
//  Item.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 29/07/25.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var plan: String = ""
    @objc dynamic var remind: Double = 0   // Offset in seconds (e.g. -86400 for 1 day before)
    @objc dynamic var repeatYearly: Bool = true
    @objc dynamic var customRemindDate: Date? = nil


    
    //inverse relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
