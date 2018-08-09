//
//  arrivalCollectionViewCell.swift
//  busBoard
//
//  Created by Blydro Klonk on 8/6/18.
//  Copyright © 2018 Blydro Klonk. All rights reserved.
//

import UIKit

class arrivalCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var whatLabel: UILabel!
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
    
    func displayArrival(_ arrival: Arrival) {
        whatLabel.text = arrival.lineName
        whereLabel.text = arrival.destination
        whenLabel.text = formatTimeDifference(arrivalTime: arrival.arrivalTime)
        
        //set cell background color
        self.backgroundColor = getLineColor(line: arrival.line)
        
        //U4 Fix
        if(arrival.line["id"] as! String == "u4") {
            whatLabel.textColor = UIColor.darkText
            whereLabel.textColor = UIColor.darkText
            whenLabel.textColor = UIColor.darkText
        } else {
            //because cells are dequeued we need to do this
            whatLabel.textColor = UIColor.white
            whereLabel.textColor = UIColor.white
            whenLabel.textColor = UIColor.white
        }
        
        //border radius to match popup
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
}
