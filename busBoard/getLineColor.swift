//
//  getLineColor.swift
//  bvgboard
//
//  Created by Blydro Klonk on 6/16/18.
//  Copyright © 2018 Blydro Klonk. All rights reserved.
//

import Foundation
import UIKit

func getLineColor(line: NSDictionary) -> UIColor {
    //default:
    var color = UIColor.lightGray
    
    //Check mode (purple for busses etc)
    if let mode = line["product"] as? String {
        if let bgColor = UIColor(named: mode) {
            color = bgColor
        }
        
        //Metrobusses are purple but metrotrams are orange! BVG so silly sometimes
        if let metro = line["metro"] as? Int {
            if(metro == 1 && mode != "bus") { //metrobusses are purple now
                if let bgColor = UIColor(named: "metro") {
                    color = bgColor
                }
            }
        }
    }
    
    //Subway and S-Bahns have different colors for differnet lines!
    if let id = line["id"] as? String {
        if let bgColor = UIColor(named: id) {
            color = bgColor
        }
    }
    
    return color
}
