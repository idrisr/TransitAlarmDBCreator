//
//  enumMaps.swift
//  DBCreator
//
//  Created by id on 4/26/16.
//  Copyright © 2016 id. All rights reserved.
//

import Foundation

enum csvfiles: Int {
    case agency
    case route
    case shape
    case stop

    func filename() -> String {
        switch self {
            case .agency: return "ctametra-agency-2016.04.26"
            case .route:  return "ctametra-routes-2016.04.26"
            case .shape:  return "ctametra-shapes-2016.04.26"
            case .stop:   return "ctametra-stops-2016.04.26"
        }
    }
}

enum StopMap: String {
    case stop_id
    case stop_lat
    case stop_lon
    case stop_name
    case stop_sequence
    case trip_id

    func name() -> String {
        switch self {
            case .stop_id:       return "id"
            case .stop_lat:      return "latitude"
            case .stop_lon:      return "longitude"
            case .stop_name:     return "name"
            case .stop_sequence: return "sequence"
            case .trip_id:       return "trip_id"
        }
    }

    static let allValues = [stop_id, stop_lat, stop_lon, stop_name, stop_sequence, trip_id]
}

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

    func transform() -> (String)->Any {
        switch self {
            case .agency_id:        return {$0}
            case .route_color:      return  {$0}
            case .route_id:         return  {$0}
            case .route_long_name:  return  {$0}
            case .route_short_name: return  {$0}
            case .route_text_color: return  {$0}
            // how to return this as int?
            case .route_type:       return {Int($0)}
            case .route_url:        return  {$0}
            case .trip_id:          return  {$0}
            case .shape_id:         return   {$0}
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

enum ShapeMap: String {
    case shape_id
    case shape_pt_lat
    case shape_pt_lon
    case shape_pt_sequence

    func name() -> String {
        switch self {
            case shape_id:          return "id"
            case shape_pt_lat:      return "latitude"
            case shape_pt_lon:      return "longitude"
            case shape_pt_sequence: return "sequence"
        }
    }

    static let allValues = [shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence]
}
