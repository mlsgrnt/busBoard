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
        
        //border radius to match popup
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }

    func formatTimeDifference(arrivalTime: Date) -> String {
        let timeDifference = arrivalTime.timeIntervalSince(Date())
        let minuteDifference = Int(ceil(timeDifference / 60))
        return minuteDifference > 0 ? String(minuteDifference) : "now"
    }
}
