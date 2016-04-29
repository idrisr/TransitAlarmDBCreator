//
//  LoadCoreData.swift
//  DBCreator
//
//  Created by id on 4/26/16.
//  Copyright © 2016 id. All rights reserved.
//

import Foundation
import UIKit
import SwiftCSV
import CoreData

class LoadCoreData {
    var moc: NSManagedObjectContext?

    class func loadCSVData() {
        let loader = LoadCoreData()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        loader.moc = appDelegate.managedObjectContext
        loader.readAgency()
        loader.readRoutes()

        NSLog("Doing Stops")
        loader.readStops()
        NSLog("Ending Stops")

        NSLog("Doing Shapes")
        loader.readShapes()
        NSLog("Ending Shapes")
    }

    // MARK: shapes
    private func readShapes() {
        let filename = csvfiles.shape.filename()
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "csv") {
            do {
                let csv = try CSV(name: path)
                csv.enumerateAsDict { dict in
                    self.loadShape(dict)
                }
            } catch let error as NSError {
                print("Error: \(error))")
            }
        }
    }

    private func loadShape(shapeDict: [String: String]) {
        // check shape doesnt exist yet. Idempotent
        let entityName = "Shape"

        let shapeID  = shapeDict[ShapeMap.shape_id.rawValue]
        let shapeLat = shapeDict[ShapeMap.shape_pt_lat.rawValue]
        let shapeLon = shapeDict[ShapeMap.shape_pt_lon.rawValue]
        let shapeSeq = shapeDict[ShapeMap.shape_pt_sequence.rawValue]

        let request = NSFetchRequest.init(entityName: entityName)
        let predicate = NSPredicate(format: "\(ShapeMap.shape_id.name())==%@ AND " +
                                            "\(ShapeMap.shape_pt_lat.name())==%@ AND " +
                                            "\(ShapeMap.shape_pt_lon.name())==%@ AND " +
                                            "\(ShapeMap.shape_pt_sequence.name())==%@", shapeID!, shapeLat!, shapeLon!, shapeSeq!)
        request.predicate = predicate

        // trip should already exist
        let route = getRouteForShapeID(shapeID!)

        do {
            let result = try self.moc!.executeFetchRequest(request)
            if result.count > 0 {
                // already exists. do nothing

            } else {
                // doesnt exist. create it
                let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.moc!)
                let shape = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.moc) as! Shape

                // add to its shapes
                for key in ShapeMap.allValues {
                    shape.setValue(shapeDict[key.rawValue], forKey: key.name())
                }
                shape.route = route
                route?.addShapesObject(shape)
            }
            do {
                try moc!.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }

    // MARK: stops
    private func readStops() {
        let filename = csvfiles.stop.filename()
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "csv") {
            do {
                let csv = try CSV(name: path)
                csv.enumerateAsDict { dict in
                    self.loadStop(dict)
                }
            } catch let error as NSError {
                print("Error: \(error))")
            }
        }
    }

    private func loadStop(stopDict: [String: String]) {
        // check stop doesnt exist yet
        let entityName = "Stop"
        let stopID = stopDict[StopMap.stop_id.rawValue]
        let tripID = stopDict[StopMap.trip_id.rawValue]
        let request = NSFetchRequest.init(entityName: entityName)
        let predicate = NSPredicate(format: "\(StopMap.stop_id.name())==%@ AND \(StopMap.trip_id.name())==%@", stopID!, tripID!)
        request.predicate = predicate

        // trip should already exist
        let route = getRouteForTripID(tripID!)

        do {
            let result = try self.moc!.executeFetchRequest(request)
            if result.count > 0 {
                // already exists. check if it is hooked up to current trip
                let stop_id = stopDict[StopMap.stop_id.rawValue]
                let stop = getStopForID(stop_id!)

                stop?.route = route
                route!.addStopsObject(stop!)

            } else {
                // doesnt exist. create it
                let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.moc!)
                let stop = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.moc) as! Stop

                // add to its stops
                for key in StopMap.allValues {
                    stop.setValue(stopDict[key.rawValue], forKey: key.name())
                }
                stop.route = route
                route?.addStopsObject(stop)
            }
            do {
                try moc!.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }

    private func getStopForID(stopID: String) -> Stop? {
        let entityName = "Stop"
        let request = NSFetchRequest.init(entityName: entityName)
        let predicate = NSPredicate(format: "\(StopMap.stop_id.name())==%@", stopID)
        request.predicate = predicate

        do {
            let result = try self.moc!.executeFetchRequest(request)
            return result.first as! Stop?
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return nil
        }
    }

    // MARK: routes
    private func readRoutes() {
        let filename = csvfiles.route.filename()
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "csv") {
            do {
                let csv = try CSV(name: path)
                csv.enumerateAsDict { dict in
                    self.loadRoutes(dict)
                }
            } catch let error as NSError {
                print("Error: \(error))")
            }
        }
    }

    private func loadRoutes(routeDict: [String: String]) {
        // check route doenst exist yet
        let entityName = "Route"
        let routeID = routeDict[RouteMap.route_id.rawValue]
        let request = NSFetchRequest.init(entityName: entityName)
        let predicate = NSPredicate(format: "\(RouteMap.route_id.name())==%@", routeID!)
        request.predicate = predicate

        do {
            let result = try self.moc!.executeFetchRequest(request)
            if result.count > 0 {
                // already exists. do nothing
                print("route with id:\(routeID) already exists")
            } else {
                // doesnt exist. create it
                print("creating route with id: \(routeID)")
                let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.moc!)
                let route = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.moc) as! Route
                let agencyID = routeDict[RouteMap.agency_id.rawValue]
                let agency = getAgencyForID(agencyID!)

                for key in RouteMap.allValues {
                    route.setValue(routeDict[key.rawValue], forKey: key.name())
                }
                route.agency = agency
                
                do {
                    try moc!.save()
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }

    }

    private func getRouteForShapeID(shapeID: String) -> Route? {
        let entityName = "Route"
        let request = NSFetchRequest.init(entityName: entityName)
        let predicate = NSPredicate(format: "\(RouteMap.shape_id.name())==%@", shapeID)
        request.predicate = predicate

        do {
            let result = try self.moc!.executeFetchRequest(request)
            return result.first as! Route?
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return nil
        }
    }

    private func getRouteForTripID(tripID: String) -> Route? {
        let entityName = "Route"
        let request = NSFetchRequest.init(entityName: entityName)
        let predicate = NSPredicate(format: "\(RouteMap.trip_id.name())==%@", tripID)
        request.predicate = predicate

        do {
            let result = try self.moc!.executeFetchRequest(request)
            return result.first as! Route?
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return nil
        }
    }

    // MARK: Agency
    private func getAgencyForID(agencyID: String) -> Agency? {
        let entityName = "Agency"
        let request = NSFetchRequest.init(entityName: entityName)
        let predicate = NSPredicate(format: "\(AgencyMap.agency_id.name())==%@", agencyID)
        request.predicate = predicate

        do {
            let result = try self.moc!.executeFetchRequest(request)
            return result.first as! Agency?
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return nil
        }
    }

    private func readAgency() {
        let filename = csvfiles.agency.filename()
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "csv") {
            do {
                let csv = try CSV(name: path)
                csv.enumerateAsDict { dict in
                    self.loadAgency(dict)
                }
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }

    private func loadAgency(agencyDict: [String: String]) {
        let entityName = "Agency"
        let agencyID = agencyDict[AgencyMap.agency_id.rawValue]
        let request = NSFetchRequest.init(entityName: entityName)
        let predicate = NSPredicate(format: "\(AgencyMap.agency_id.name())==%@", agencyID!)
        request.predicate = predicate

        do {
            let result = try self.moc!.executeFetchRequest(request)
            if result.count > 0 {
                // already exists. do nothing
                print("agency with id:\(agencyID) already exists")
            } else {
                // doesnt exist. create it
                print("creating agency with id: \(agencyID)")
                let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.moc!)
                let agency = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.moc)

                for key in AgencyMap.allValues {
                    agency.setValue(agencyDict[key.rawValue], forKey: key.name())
                }

                do {
                    try moc!.save()
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }

}
