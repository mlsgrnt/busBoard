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
    let lineProduct: String
    let nextStop: NSDictionary
    var score: Double?
    let platform: String?
    var usefulRemarks: [String]
    var warnings: [NSDictionary]
    
    init(from apiDump: json) {
        self.arrivalTime = formatDate(apiDump["when"] as! String)
        self.coordinates = [((apiDump["stop"] as! NSDictionary)["location"] as! NSDictionary), ((apiDump["nextStop"] as! NSDictionary)["location"] as! NSDictionary)]
        self.delay = apiDump["delay"] as? Int ?? 0
        self.destination = cleanStationName(apiDump["direction"] as! String)
        self.id = apiDump["tripId"] as! String //this is not entirely unique but works for equtability
        self.line = apiDump["line"] as! NSDictionary
        self.lineName = generatePrettyLineName(self.line)
        self.nextStop = apiDump["nextStop"] as! NSDictionary
        self.platform = apiDump["platform"] as? String
        
        //make line product type prettier:
        var lineProduct = self.line["product"] as! String
        if(lineProduct == "suburban") {
            lineProduct = "S-Bahn"
        }
        if(lineProduct == "subway") {
            lineProduct = "U-Bahn"
        }

        self.lineProduct = lineProduct
        
        self.usefulRemarks = []
        self.warnings = []
        
        var barrierFree = false
        
        for remark in apiDump["remarks"] as! NSArray {
            guard let remark = remark as? NSDictionary else {
                return //something went wrong
            }
            
            if let code = remark["code"] as? String {
                if(code == "bf") {
                    barrierFree = true
                    continue //"secure by default" vibe
                    //only show a message if it's NOT barrier free.
                }
                if(code == "FB") {
                    continue //fuck bikes
                    //TODO: others may not agree
                }
                if(code == "EH") {
                    continue //what even is "vehicle-mounted accessaid"
                }
            }
            /* temporarily disabled because of the stupid new api
            if(remark["type"] as! String == "warning") {
                self.warnings.append(remark)
                continue
            }
            */
            guard let remarkText = remark["text"] as? String else {
                continue //nothing to see here
            }
            self.usefulRemarks.append(remarkText)
            
            if(barrierFree == false) {
                self.usefulRemarks.append("Not wheelchair accessible!")
            }
        }
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

