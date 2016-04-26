//
//  Route+CoreDataProperties.swift
//  DBCreator
//
//  Created by id on 4/26/16.
//  Copyright © 2016 id. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Route {

    @NSManaged var color: String?
    @NSManaged var long_name: String?
    @NSManaged var short_name: String?
    @NSManaged var text_color: String?
    @NSManaged var type: String?
    @NSManaged var url: String?
    @NSManaged var trip_id: String?
    @NSManaged var shape_id: String?
    @NSManaged var id: String?
    @NSManaged var agency: Agency?
    @NSManaged var stops: NSSet?

    @NSManaged func addStopsObject(stop: Stop)
    @NSManaged func removeStopsObject(stop: Stop)
    @NSManaged func addStops(stops: NSSet)
    @NSManaged func removeStops(stops: NSSet)
}
