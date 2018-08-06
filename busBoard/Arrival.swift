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
    let coordinates: [NSDictionary]
    let delay: Int
    let destination: String
    let id: String
    let line: NSDictionary
    let lineName: String
    var score: Double?
    
    init(from apiDump: json) {
        self.arrivalTime = formatDate(apiDump["when"] as! String)
        self.coordinates = [((apiDump["station"] as! NSDictionary)["location"] as! NSDictionary), ((apiDump["nextStation"] as! NSDictionary)["location"] as! NSDictionary)]
        self.delay = apiDump["delay"] as? Int ?? 0
        self.destination = cleanStationName(apiDump["direction"] as! String)
        self.id = apiDump["journeyId"] as! String //this is not entirely unique but works for equtability
        self.line = apiDump["line"] as! NSDictionary
        self.lineName = generatePrettyLineName(self.line)
        
    }
    
    //equitability
    static func == (lhs: Arrival, rhs: Arrival) -> Bool {
        return lhs.id == rhs.id
    }
    
    //this could be cleaner...
    public func getScore(orientation: Double) {
        let here = [self.coordinates[0]["latitude"] as! Double, self.coordinates[0]["longitude"] as! Double]
        let there = [self.coordinates[1]["latitude"] as! Double, self.coordinates[1]["longitude"] as! Double]
        
        let me = Vector2(Scalar(cos(orientation * Double.pi / 180)), Scalar(sin(orientation * Double.pi / 180)))
        let you = Vector2(Scalar(there[0] - here[0]), Scalar(there[1] - here[1]))
        
        score = Double(you.dot(me))
    }
}

func formatDate(_ dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZ"
    return dateFormatter.date(from: dateString)!
}

func generatePrettyLineName(_ line: NSDictionary) -> String {
    var symbol: String
    if let stringSymbol = line["symbol"] as? String {
        symbol = stringSymbol
    } else {
        symbol = ""
    }
    
    var lineNr: String
    if let lineNumber = line["nr"] as? Int {
        lineNr = String(lineNumber)
    } else {
        guard let lineNumber = line["nr"] as? String else {
            return symbol
        }
        lineNr = lineNumber
    }
    
    return symbol + lineNr
}

