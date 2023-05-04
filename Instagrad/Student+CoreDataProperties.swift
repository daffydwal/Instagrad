//
//  Student+CoreDataProperties.swift
//  Instagrad
//
//  Created by David Wale on 24/04/2023.
//
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student")
    }

    @NSManaged public var attending: String?
    @NSManaged public var ceremonyCode: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var order: Int32
    @NSManaged public var studNum: String?
    @NSManaged public var timeOff: Int32
    @NSManaged public var timeOffFriendly: String?
    @NSManaged public var timeOn: Int32
    @NSManaged public var timeOnFriendly: String?
    @NSManaged public var index: Int16
    @NSManaged public var audioTimeOn: Double
    @NSManaged public var audioTimeOff: Double
    
    var wrappedceremonyCode: String {
        ceremonyCode ?? "Unknown"
    }

}

extension Student : Identifiable {

}
