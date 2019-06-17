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
        #if DEBUG
        let url = "http://192.168.2.104:5000/nearby.json"
        #else
        let url = "https://vbb-rest.glitch.me/stations/nearby?latitude=\(latitude)&longitude=\(longitude)"
        #endif
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default)
        //Alamofire.request(, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let result = response.result.value {
                    let JSON = result as! NSArray
                    guard let nearestStation = JSON[0] as? json else {
                        fatalError("not in beriln")
                    }
                    self.nearestStationName = cleanStationName(nearestStation["name"] as! String)
                    completion()
                    self.getDepartures(stationId: nearestStation["id"] as! String)
                }
                
        }
    }
    
    private func getDepartures(stationId: String, duration: Int = 30) {
        print("aaah getting departures better pray i don't do this too often")
        
        #if DEBUG
        let url = "http://192.168.2.104:5000/departures.json"
        #else
        let url = "https://vbb-rest.glitch.me/stations/\(stationId)/departures?duration=\(duration)"
        #endif
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default)
        //Alamofire.request(, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let result = response.result.value {
                    guard let JSON = result as? NSArray else {
                        //what in the world
                        print(result)
                        fatalError("JSON wasn't array!")
                    }
                    
                    //real quick before we load in new ones
                    self.allArrivals.removeAll()
                    for arrival in JSON {
                        //Don't add cacnelled trips!
                        if((arrival as! json)["cancelled"] == nil) {
                            self.allArrivals.append(Arrival(from: arrival as! json))
                        }
                    }
                    
                    //create stationLineCount with amazing hacxx. It's not perfect but it provides a good enough heuristic
                    //first let's check for no departures at all
                    if(self.allArrivals.count == 0) {
                        //bad start. let's increase right away
                        self.getDepartures(stationId: stationId, duration: duration + 100)
                        return
                    }
                    //are you ready for this ALGORITHM
                    var stationLineCount = 0
                    if let lines = (((JSON[0] as! json)["stop"] as! json)["lines"] as? NSArray) {
                        stationLineCount = lines.filter({ (line) -> Bool in
                            return (line as! NSDictionary)["night"] as! Int == 0
                        }).count
                    }
                    
                    //check that we have at least 2 departures for each line (one for each direction)
                    guard self.allArrivals.count > stationLineCount * 2 else {
                        //we need bigger guns
                        self.getDepartures(stationId: stationId, duration: duration + 60)
                        return
                    }
                }
                
                //No update now! Update occurs on filter!
        }
    }
    
    public func getStationsAlong(journeyId: String, completion: @escaping (_: NSArray) -> Void) {
        let safeJourneyId = journeyId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        #if DEBUG
        let requestUrl = "http://192.168.2.104:5000/leg.json"
        #else
        let requestUrl = "https://vbb-rest.glitch.me/journeys/legs/\(safeJourneyId!)?lineName=null"
        #endif
        
        Alamofire.request(requestUrl, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let result = response.result.value {
                    guard let JSON = result as? NSDictionary else {
                        //what in the world
                        print(result)
                        fatalError("JSON wasn't array!")
                    }
                    completion(JSON["passed"] as! NSArray)
                }
        }
    }
    
    //BAD CODE AHEAD
    //THIS IS THE SORTING PART
    //IT'S REALLY REALLY BAD
    func filterArrivalsByCompassDirection(direction orientation: Double, completion: @escaping () -> Void) {
        //if we don't have any arrivals, let's do nothing
        //TODO: display a message!
        if(self.allArrivals.count == 0) {
            return
        }
        
        //before we do anything else, let's be both realistic and useful and only show stuff in the next 60 minutes
        var soonArrivals = self.allArrivals.filter { (arrival: Arrival) -> Bool in
            return arrival.arrivalTime.timeIntervalSince(Date()) < 3600
        }
        if(soonArrivals.count == 0) {
            soonArrivals = self.allArrivals
        }
        
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
        })
        
        
        
        //completion() is an animation, so only run it if we have a change!
        if(self.arrivals != filtered) {
            self.arrivals = filtered
            completion()
        }
    }
}

