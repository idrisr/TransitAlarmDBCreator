//
//  ViewController.swift
//  DBCreator
//
//  Created by id on 4/24/16.
//  Copyright © 2016 id. All rights reserved.
//

enum RouteMap:String {

    case agency_id
    case route_color
    case route_id
    case route_long_name
    case route_short_name
    case route_text_color
    case route_type
    case route_url
    case trip_id
    case shape_id

    func name() -> String {
        switch self {
            case .agency_id:        return "agency_id"
            case .route_color:      return "color"
            case .route_id:         return "id"
            case .route_long_name:  return "long_name"
            case .route_short_name: return "short_name"
            case .route_text_color: return "text_color"
            case .route_type:       return "type"
            case .route_url:        return "url"
            case .trip_id:          return "trip_id"
            case .shape_id:         return "shape_id"
        }
    }

    func toType() -> String {
        switch self {
            case .agency_id:        return "agency_id"
            case .route_color:      return "color"
            case .route_id:         return "id"
            case .route_long_name:  return "long_name"
            case .route_short_name: return "short_name"
            case .route_text_color: return "text_color"

        // how to return this as int?
            case .route_type:       return "type"
            case .route_url:        return "url"
            case .trip_id:          return "trip_id"
            case .shape_id:         return "shape_id"
        }
    }

    static let allValues = [route_color, route_id, route_long_name,
        route_short_name, route_text_color, route_type, route_url, trip_id,
        shape_id]

}

enum AgencyMap:String {
    case agency_id
    case agency_name
    case agency_url
    case agency_timezone
    case agency_lang

    func name() -> String {
        switch self {
            case .agency_id:       return "id"
            case .agency_name:     return "name"
            case .agency_url:      return "url"
            case .agency_timezone: return "timezone"
            case .agency_lang:     return "language"
        }
    }

    static let allValues = [agency_id, agency_name, agency_url, agency_timezone, agency_lang]
}

import UIKit
import CoreData
import SwiftCSV

class ViewController: UIViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        moc = appDelegate.managedObjectContext
        readAgency()
        readRoutes()
    }

    private func readRoutes() {
        let filename = "ctametra-routes-2016.04.26"
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "csv") {
            do {
                let csv = try CSV(name: path)
                csv.enumerateAsDict { dict in
                    self.loadRoutes(dict)
                }
            } catch {
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

                // set its agency


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
        let filename = "ctametra-agency-2016.04.26"
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

    private func loadTrip(trip:[String: String]) {
    }

    private func loadStop(stop:[String: String]) {
    }

    private func loadShape(shape:[String: String]) {
    }

    private func getAgency() {

    }

    private func loadDumb() {
        super.viewDidLoad()

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        var entity = NSEntityDescription.entityForName("Agency", inManagedObjectContext: moc)
        let agency = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc)
        agency.setValue("CTA", forKey: "name")

        do {
            try moc.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }

        entity = NSEntityDescription.entityForName("Route", inManagedObjectContext: moc)
        let route1 = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc)
        route1.setValue("Red Line", forKey: "name")
        route1.setValue(agency, forKey: "Agency")

        do {
            try moc.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }

        let route2 = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc)
        route2.setValue("Blue Line", forKey: "name")
        route2.setValue(agency, forKey: "Agency")

        do {
            try moc.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }

    }
}
