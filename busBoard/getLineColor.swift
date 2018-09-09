//
//  getLineColor.swift
//  bvgboard
//
//  Created by Blydro Klonk on 6/16/18.
//  Copyright © 2018 Blydro Klonk. All rights reserved.
//
import Foundation
import UIKit

func getLineColor(direction: String) -> UIColor {
    //default:
    var color = UIColor.lightGray
    
    print(direction)
    
    if (direction == "inbound") {
        color = UIColor.orange
    }
    if (direction == "outbound") {
        color = UIColor(named: "s8")!
    }
    
    return color
}
