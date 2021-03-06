//
//  AllStationsTableViewController.swift
//  
//
//  Created by Blydro Klonk on 8/13/18.
//

import UIKit

class AllStationsTableViewController: UITableViewController {
    
    let api = API.sharedInstance
    
    var arrival: Arrival?
    var stations: NSArray?
    
    var hasScrolled: Bool?
        
    override func viewWillAppear(_ animated: Bool) {
        let journeyId = self.arrival?.id
        api.getStationsAlong(journeyId: journeyId!) { (allStations) in
            self.stations = allStations
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "All Stations"

    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let stations = self.stations else {
            return 0
        }
        return stations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell", for: indexPath) as! StationTableViewCell

        let journeySection = stations![indexPath.row] as! NSDictionary
        let station = journeySection["station"] as! NSDictionary
        
        var departureTime = "2019-01-01T00:00:00.000000+0200"
        
        if let arrivalTime = journeySection["arrival"] as? NSString {
            departureTime = arrivalTime as String
        }
        if let realDepartureTime = journeySection["departure"] as? NSString {
            departureTime = realDepartureTime as String
        }
        
        // Get relative time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZ"
        let departureDate = dateFormatter.date(from: departureTime)!
        var naturalDepartureTime = getShortRelativeDateFor(date: departureDate as NSDate)
        
        
        // Add conditional ago
        if departureDate.timeIntervalSinceNow < 0 {
            naturalDepartureTime = naturalDepartureTime + " ago"
        }
        
        var blobType = "mid"
        
        // Configure the cell...
        cell.stationNameLabel.text = cleanStationName(station["name"] as! String)
        cell.arrivalTimeLabel.text = naturalDepartureTime
        
        if(indexPath.row == 0 || indexPath.row == stations!.count - 1) {
            cell.stationNameLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
            blobType = indexPath.row == stations!.count - 1 ? "end" : "start"
        } else {
            cell.stationNameLabel.font = UIFont.systemFont(ofSize: 22.0)
        }
        
        if(cell.stationNameLabel.text == api.nearestStationName) {
            cell.stationNameLabel.backgroundColor = UIColor.lightGray //TODO: REFINE THIS!!!
            if(self.hasScrolled != true) {
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                self.hasScrolled = true
            }
        } else {
            cell.stationNameLabel.backgroundColor = UIColor.white
        }
        
        cell.blobView.setBlobType(color: getLineColor(line: arrival!.line), type: blobType)

        //force redraw
        cell.blobView.setNeedsDisplay()
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
