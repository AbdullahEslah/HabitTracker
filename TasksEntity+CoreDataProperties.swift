//
//  TasksEntity+CoreDataProperties.swift
//  Smart Tracking Tasks
//
//  Created by Abdallah Eslah on 26/08/2025.
//
//

import Foundation
import CoreData


extension TasksEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TasksEntity> {
        return NSFetchRequest<TasksEntity>(entityName: "TasksEntity")
    }

    @NSManaged public var habitName: String?
    @NSManaged public var habitStatus: String?
    @NSManaged public var id: String?

}

extension TasksEntity : Identifiable {

}
