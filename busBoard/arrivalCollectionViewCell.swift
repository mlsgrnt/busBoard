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
        
        //shadow!
        let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)  //Here you control x and y
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 3.0 //Here your control your blur
        self.layer.masksToBounds =  false
        self.layer.shadowPath = shadowPath.cgPath
    }
}
