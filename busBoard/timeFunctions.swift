//
//  formatTimeDifference.swift
//  
//
//  Created by Blydro Klonk on 8/7/18.
//

import Foundation

func formatTimeDifference(arrivalTime: Date) -> String {
    let timeDifference = arrivalTime.timeIntervalSince(Date())
    let minuteDifference = Int(ceil(timeDifference / 60))
    return minuteDifference > 0 ? String(minuteDifference) : "now"
}

func getDiffString(arrivalTime: Date) -> String {
    let timeDifference = arrivalTime.timeIntervalSince(Date())
    let minuteDifference = Int(ceil(timeDifference / 60))
    return minuteDifference > 0 ? String(minuteDifference) + (minuteDifference == 1 ? " minute " : " minutes ") : "Less than a minute"
}

func getDelayString(arrival: Arrival) -> String {
    let delay = arrival.delay / 60 //seconds -> minutes
    
    //delay string
    var delayString = "No realtime info available"
    if(delay == 0) {
        delayString = "On time"
    }
    if(delay > 0 || delay < 0) {
        delayString = String(abs(delay)) + (abs(delay) == 1 ? " minute " : " minutes ") + (delay < 0 ? "early" : "late")
    }
    return delayString
}

// https://stackoverflow.com/a/29773588
func getShortRelativeDateFor(date: NSDate) ->String {
    
    let timeInterval = abs(date.timeIntervalSinceNow)
    
    switch timeInterval {
    case 0..<60:
        return String(format: "%.fs", timeInterval)
    case 60..<(60 * 60):
        return String(format: "%.fm", timeInterval / 60)
    case (60 * 60)..<(60 * 60 * 24):
        return String(format: "%.fh", timeInterval / (60 * 60))
    case (60 * 60 * 24)..<(60 * 60 * 24 * 365):
        return String(format: "%.fd", timeInterval / (60 * 60 * 24))
    default:
        return String(format: "%.fy", timeInterval / (60 * 60 * 24 * 365))
    }
}
