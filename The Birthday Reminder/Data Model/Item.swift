//
//  Item.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 29/07/25.
//

import Foundation
import RealmSwift

class Item: Object {
        //@Persisted === @objc dynamic var
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var date: Date = Date()
    @Persisted var plan: String = ""
    @Persisted var remind: Double = 0   // Offset in seconds (e.g. -86400 for 1 day before)
    @Persisted var repeatYearly: Bool = true
    @Persisted var customRemindDate: Date? = nil
    //save hex string in color as realm takes standard datatypes not UIColor...
    @Persisted var color : String = ""


    
    //inverse relationship
    //var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    @Persisted(originProperty: "items") var parentCategory: LinkingObjects<Category>
}
