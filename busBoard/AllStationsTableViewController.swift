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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        
        // Configure the cell...
        cell.stationNameLabel.text = cleanStationName(station["name"] as! String)
        
        if(indexPath.row == 0 || indexPath.row == stations!.count - 1) {
            cell.stationNameLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        } else {
            cell.stationNameLabel.font = UIFont.systemFont(ofSize: 18.0)
        }
        
        if(cell.stationNameLabel.text == api.nearestStationName) {
            cell.backgroundColor = UIColor.green
        } else {
            cell.backgroundColor = UIColor.white
        }

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
