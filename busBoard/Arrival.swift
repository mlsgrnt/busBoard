//
//  Arrival.swift
//  busBoard
//
//  Created by Blydro Klonk on 8/6/18.
//  Copyright © 2018 Blydro Klonk. All rights reserved.
//
import Foundation
import VectorMath

class Arrival: Equatable {
    let arrivalTime: Date
    let delay: Double
    let destination: String
    let id: String
    let lineName: String
    let direction: String
    let platform: String?
    
    init(from apiDump: json) {
        if let bestArrivalTime = apiDump["expected_departure_time"] as? String {
            self.arrivalTime = formatDate(apiDump["expected_departure_date"] as! String + "T" + bestArrivalTime)
            self.delay = self.arrivalTime.timeIntervalSince(formatDate(apiDump["expected_departure_date"] as! String + "T" + (apiDump["aimed_departure_time"] as! String)))
        } else {
            let bestArrivalTime = apiDump["aimed_departure_time"] as! String
            self.arrivalTime = formatDate(apiDump["date"] as! String + "T" + bestArrivalTime)
            self.delay = 0 //TODO: this shoudl be nil and then displayed appropriately
        }
        
        self.destination = apiDump["direction"] as! String
        self.id = apiDump["id"] as! String //this is not entirely unique but works for equtability
        self.lineName = apiDump["line_name"] as! String
        self.direction = apiDump["dir"] as! String
        self.platform = apiDump["platform"] as? String
    }
    
    //equitability
    static func == (lhs: Arrival, rhs: Arrival) -> Bool {
        return lhs.id == rhs.id
    }
    
}

func formatDate(_ dateString: String) -> Date {
    //TODO: this is still super wonky... timezones............
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
    return dateFormatter.date(from: dateString)!
}
