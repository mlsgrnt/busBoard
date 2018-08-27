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
    @IBOutlet weak var arrivingInSTATICLabel: UILabel!
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
        
        //U4 text color fix
        //todo: opacity
        if(arrival.line["id"] as! String == "u4") {
            lineNameLabel.textColor = UIColor.darkText
            lineDestinationLabel.textColor = UIColor.darkText
            delayLabel.textColor = UIColor.darkText
            arrivingInSTATICLabel.textColor = UIColor.darkText
            when1Label.textColor = UIColor.darkText
            when2Label.textColor = UIColor.darkText
            when3Label.textColor = UIColor.darkText
            remarksLabel.textColor = UIColor.darkText
        }
        
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
        
        
        //It is safe to only incrmenet this by one and then not check again because you know what if it's the same a third time than maybe this bus really is showing up that often
        //sometimes it's not the software's fault it's the transit company's fault
        
        //TODO: while loop?
        var arrivalCounter = 0
        
        when1Label.text = getDiffString(arrivalTime: nextArrivals[arrivalCounter].arrivalTime)
        if(nextArrivals.count > 1) {
            arrivalCounter += 1
            
            if(nextArrivals[arrivalCounter].arrivalTime == nextArrivals[arrivalCounter - 1].arrivalTime) {
                arrivalCounter += 1 //push it even further if it's the same
            }
            when2Label.text = getDiffString(arrivalTime: nextArrivals[arrivalCounter].arrivalTime)
            if(nextArrivals.count > 2) {
                arrivalCounter += 1
                
                if(nextArrivals[arrivalCounter].arrivalTime == nextArrivals[arrivalCounter - 1].arrivalTime) {
                    arrivalCounter += 1 //push it even further if it's the same
                }
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
        self.title = arrival.lineProduct.capitalized
        
        //setup navbar
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stops", style: .plain, target: self, action: #selector(stopsTapped))
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let AllStationsTableViewController = segue.destination as? AllStationsTableViewController else {
            fatalError()
        }
        AllStationsTableViewController.arrival = self.arrival
    }
    @objc func stopsTapped() {
        self.performSegue(withIdentifier: "viewAllStops", sender: self)
    }
}

