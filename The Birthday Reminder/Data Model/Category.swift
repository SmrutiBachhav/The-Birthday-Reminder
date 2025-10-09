//
//  Category.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 04/09/25.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name : String = ""
    //save hex string in color as realm takes standard datatypes not UIColor...
    @Persisted var color : String = ""
    //@Persisted === @objc dynamic var
    //forward relation
    //let items = List<Item>() //contains list of item object
    @Persisted var items = List<Item>()
}
