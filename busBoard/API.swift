//
//  APIClient.swift
//  busBoard
//
//  Created by Blydro Klonk on 8/6/18.
//  Copyright © 2018 Blydro Klonk. All rights reserved.
//

import Foundation
import Alamofire

typealias json = [String: Any]

class API {
    //create singleton
    static let sharedInstance = API()
    
    var arrivals: [Arrival]
    var allArrivals: [Arrival]
    var nearestStationName: String?
    var nearestStationType: String?
    
    init() {
        arrivals = [Arrival]()
        allArrivals = [Arrival]()
    }
    
    //Arrival Functions
    func clearArrivals(completion: @escaping () -> Void) {
        arrivals = [Arrival]()
        allArrivals = [Arrival]()
        completion()
    }
    
    func getArrivals(longitude: Double, latitude: Double, completion: @escaping () -> Void) {
        Alamofire.request("https://transportapi.com/v3/uk/bus/stops/near.json?app_id=e02c6fd6&app_key=593a37a8e30eaa9cff1c04c5530c67e8&lat=\(latitude)&lon=\(longitude)", method: .get, encoding: JSONEncoding.default)
        //Alamofire.request("https://transportapi.com/v3/uk/bus/stops/near.json?lat=55.882574&lon=-4.277300&app_id=e02c6fd6&app_key=593a37a8e30eaa9cff1c04c5530c67e8", method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let result = response.result.value {
                    let JSON = result as! NSDictionary
                    let stopsJSON = JSON["stops"] as! NSArray
                    guard let nearestStation = stopsJSON[0] as? json else {
                        fatalError("not in glasgow")
                    }
                    self.nearestStationName = nearestStation["name"] as? String
                    self.nearestStationType = nearestStation["mode"] as? String
                    completion()
                    self.getDepartures(stationId: nearestStation["atcocode"] as! String)
                }
                
        }
    }
    
    private func getDepartures(stationId: String, duration: Int = 30) {
        print("aaah getting departures better pray i don't do this too often")
        
        let requestUrl = self.nearestStationType == "bus" ? "/uk/bus/stop/\(stationId)/live.json" : "/uk/train/station/\(stationId)/live.json"
        
        Alamofire.request("https://transportapi.com/v3/\(requestUrl)?group=no&app_id=e02c6fd6&app_key=593a37a8e30eaa9cff1c04c5530c67e8", method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let result = response.result.value {
                    guard let JSON = result as? NSDictionary else {
                        //what in the world
                        fatalError("JSON wasn't proper!")
                    }
                    
                    //real quick before we load in new ones
                    self.allArrivals.removeAll()
                    let departures = (JSON["departures"] as! NSDictionary)["all"] as! NSArray
                    for departure in departures {
                        self.allArrivals.append(Arrival(from: departure as! json))
                    }
                }
                
                //No update now! Update occurs on filter!
        }
    }
    
    //this function name is a lie
    func filterArrivalsByCompassDirection(direction orientation: Double, completion: @escaping () -> Void) {
        //before we do anything else, let's be both realistic and useful and only show stuff in the next 60 minutes
        let soonArrivals = self.allArrivals.filter { (arrival: Arrival) -> Bool in
            return arrival.arrivalTime.timeIntervalSince(Date()) < 999999999999999999999//3600
        }
        
        if(self.allArrivals.count == 0) {
            return
        }
        /*
        var filtered = [Arrival]()
        
        let sortedByLine = soonArrivals.reduce(into: [String:[Arrival]]()) { (dict, entry) in
            let key = entry.line.value(forKey: "id") as! String
            if var existingArray = dict[key] {
                existingArray.append(entry)
                dict[key] = existingArray
                return
            }
            dict[key] = [entry]
            
        }
        
        var linesAndTheirDestinations = [String:[Arrival]]()
        for line in sortedByLine {
            let lineName = line.key
            let arrivals = line.value
            
            linesAndTheirDestinations[lineName] = arrivals
                .reduce(into: [Arrival]()) { (arrivals, arrival) in
                    if arrivals.first(where: {$0.destination == arrival.destination}) == nil {
                        //get the score for this arrival -- useful later!
                        arrival.getScore(orientation: orientation)
                        arrivals.append(arrival)
                    }
                }
                .sorted(by: { (a, b) -> Bool in
                    return a.score! > b.score!
                })
                .reduce(into: [Arrival](), { (arrivals, arrival) in
                    //adding only while the score is the same (or being the first) we can figure out exactly which destinations are in our direction
                    if(arrivals.count == 0 || arrivals[arrivals.count - 1].score == arrival.score) {
                        arrivals.append(arrival)
                    }
                })
            
        }
        //super awesome, not hacky way to put our well filtered stuff into the final filtered array
        for line in linesAndTheirDestinations {
            let arrivals = line.value
            //TODO: sort by time in case there is a weird problem?
            filtered.append(arrivals[0])
        }
        
        filtered = filtered.sorted(by: { (a, b) -> Bool in
            a.arrivalTime < b.arrivalTime
        })*/
        
        
        
        //completion() is an animation, so only run it if we have a change!
        if(self.arrivals != soonArrivals) {
            self.arrivals = soonArrivals
            completion()
        }
    }
}

