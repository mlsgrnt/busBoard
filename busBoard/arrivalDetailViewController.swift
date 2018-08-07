//
//  arrivalDetailViewController.swift
//  busBoard
//
//  Created by Blydro Klonk on 8/6/18.
//  Copyright © 2018 Blydro Klonk. All rights reserved.
//

import UIKit

class arrivalDetailViewController: UIViewController {

    @IBOutlet weak var platformStackView: UIStackView!
    @IBOutlet weak var platformNumberLabel: UILabel!
    @IBOutlet weak var lineNameLabel: UILabel!
    @IBOutlet weak var lineDestinationLabel: UILabel!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var when1Label: UILabel!
    @IBOutlet weak var when2Label: UILabel!
    @IBOutlet weak var when3Label: UILabel!
    @IBOutlet weak var remarksStackView: UIStackView!
    @IBOutlet weak var remarksLabel: UILabel!
    
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
        
        //check for platform and if there is one set it
        if(arrival.platform != nil) {
            platformStackView.isHidden = false
            platformNumberLabel.text = arrival.platform
        }
        
        //set labels
        lineNameLabel.text = arrival.lineName
        lineDestinationLabel.text = arrival.destination
        delayLabel.text = getDelayString(arrival: arrival)
        
        //set next arrival labels
        let api = API.sharedInstance
        let nextArrivals = api.allArrivals
            .filter { (nextArrival) -> Bool in
                return nextArrival.nextStop["id"] as! String == arrival.nextStop["id"] as! String && nextArrival.line["id"] as! String == arrival.line["id"] as! String
            }
            .sorted { (a, b) -> Bool in
                return a.arrivalTime < b.arrivalTime
        }
        
        when1Label.text = getDiffString(arrivalTime: nextArrivals[0].arrivalTime)
        if(nextArrivals.count > 1) {
            when2Label.text = getDiffString(arrivalTime: nextArrivals[1].arrivalTime)
            if(nextArrivals.count > 2) {
                when3Label.text = getDiffString(arrivalTime: nextArrivals[2].arrivalTime)
            }
        }
        
        //check for remarks
        if(arrival.usefulRemarks.count > 0) {
            remarksStackView.isHidden = false
            
            var allRemarks = ""
            for remark in arrival.usefulRemarks {
                allRemarks += "\(remark)" + "\n"
            }
            remarksLabel.text = allRemarks
        }
        
        //set a title
        //TODO: make these titles a little more friendly
        self.title = (arrival.line["product"] as? String)?.capitalized
        
        //setup navbar
        self.navigationItem.largeTitleDisplayMode = .never
    }
}

