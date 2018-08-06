//
//  arrivalDetailViewController.swift
//  busBoard
//
//  Created by Blydro Klonk on 8/6/18.
//  Copyright © 2018 Blydro Klonk. All rights reserved.
//

import UIKit

class arrivalDetailViewController: UIViewController {

    @IBOutlet weak var lineNameLabel: UILabel!
    @IBOutlet weak var lineDestinationLabel: UILabel!
    
    public var arrival: Arrival?
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //view.frame = self.view.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check for arrival
        guard let arrival = self.arrival else {
            fatalError("arrival detail view wasn't passsed an arrival!")
        }
        
        //line based background color
        self.view.backgroundColor = getLineColor(line: arrival.line)
        
        //set labels
        lineNameLabel.text = arrival.lineName
        lineDestinationLabel.text = arrival.destination
        
        //set a title
        self.title = (arrival.line["product"] as? String)?.capitalized
    }
}

