//
//  User+CoreDataProperties.swift
//  CRUDPelindo_Test
//
//  Created by Hastomi Riduan Munthe on 25/07/23.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var namalengkap: String?
    @NSManaged public var password: String?
    @NSManaged public var status: String?
    @NSManaged public var userid: Int64
    @NSManaged public var username: String?

}

extension User : Identifiable {

}
