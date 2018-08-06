//
//  cleanStationName.swift
//  bvgboard
//
//  Created by Blydro Klonk on 6/14/18.
//  Copyright © 2018 Blydro Klonk. All rights reserved.
//

import Foundation

func cleanStationName(_ dirty: String) -> String {
    var clean = dirty
    
    //split off place names
    if let splat = clean.components(separatedBy: ", ").count > 1 ? clean.components(separatedBy: ", ")[1] : nil as String?  {
        if(splat.count > 4) {
            clean = splat
        }
    }
    
    //split off s+u
    //TODO: this doesn't feel very swifty, but it works!
    var splat = clean.components(separatedBy: "S ")
    if(splat.count > 1) {
        clean = splat[1]
    }
    splat = clean.components(separatedBy: "U ")
    if(splat.count > 1) {
        clean = splat[1]
    }
    
    //split away weird brackets
    splat = clean.components(separatedBy: "[")
    if(splat.count > 1) {
        clean = splat[0]
    }
    
    //clean ringbahn
    splat = clean.components(separatedBy: "S41 ")
    if(splat.count > 1) {
        clean = splat[1]
    }
    splat = clean.components(separatedBy: "S42 ")
    if(splat.count > 1) {
        clean = splat[1]
    }
    
    
    return clean
}
