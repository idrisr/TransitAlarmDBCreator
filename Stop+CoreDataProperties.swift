//
//  Stop+CoreDataProperties.swift
//  DBCreator
//
//  Created by id on 4/29/16.
//  Copyright © 2016 id. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Stop {

    @NSManaged var id: String?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    @NSManaged var name: String?
    @NSManaged var sequence: String?
    @NSManaged var trip_id: String?
    @NSManaged var underground: NSNumber?
    @NSManaged var route: Route?

}
