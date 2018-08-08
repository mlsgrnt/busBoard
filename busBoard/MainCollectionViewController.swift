
//
//  ViewController.swift
//  busBoard
//
//  Created by Blydro Klonk on 8/6/18.
//  Copyright © 2018 Blydro Klonk. All rights reserved.
//

import UIKit
import CoreLocation
import PeekPop

class MainCollectionViewController: UICollectionViewController, CLLocationManagerDelegate, PeekPopPreviewingDelegate {

    //, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //Outlets
    @IBOutlet var mainCollectionView: UICollectionView!
    
    var peekPop: PeekPop?
    let locationManager = CLLocationManager()
    
    let api = API.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("getting location")
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            //locationManager.startMonitoringSignificantLocationChanges()
            locationManager.requestLocation()
            locationManager.headingFilter = 0.000000000000001
            locationManager.startUpdatingHeading()
        } else {
            fatalError("u need location, dummy")
        }
        
        peekPop = PeekPop(viewController: self)
        peekPop?.registerForPreviewingWithDelegate(self, sourceView: collectionView!)
    }
    
    //MARK: - peekpop stuff
    func previewingContext(_ previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        if let previewViewController = storyboard.instantiateViewController(withIdentifier: "arrivalDetail") as? arrivalDetailViewController {
            if let indexPath = collectionView!.indexPathForItem(at: location) {
                let arrival = api.arrivals[indexPath.item]
                if let layoutAttributes = collectionView!.layoutAttributesForItem(at: indexPath) {
                    previewingContext.sourceRect = layoutAttributes.frame
                }
                previewViewController.arrival = arrival
                return previewViewController
            }
            
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController) {    
        self.navigationController?.pushViewController(viewControllerToCommit, animated: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        if let previewViewController = storyboard.instantiateViewController(withIdentifier: "arrivalDetail") as? arrivalDetailViewController {
            self.navigationController?.pushViewController(previewViewController, animated: true)
            previewViewController.arrival = api.arrivals[indexPath.item]
        }
    }
    
    //MARK: - Location Stuff
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        fatalError("location error: \(error)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        api.getArrivals(longitude: location.longitude, latitude: location.latitude, completion: {
            DispatchQueue.main.async {
                self.navigationItem.title = self.api.nearestStationName
            }
        })
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        locationManager.headingFilter = 1 //once we get the first heading, decrease the accuracy
        api.filterArrivalsByCompassDirection(direction: Double(newHeading.magneticHeading), completion: {
            DispatchQueue.main.async {
                self.collectionView?.reloadSections(IndexSet(integer: 0))
            }
        })
    }
    func stopUpdatingHeading() {
        self.locationManager.stopUpdatingHeading()
    }
    
    //MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (self.view.bounds.size.width - 10)
        return CGSize(width: size, height: size)
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return api.arrivals.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "arrivalCollectionViewCell", for: indexPath) as! arrivalCollectionViewCell
        let arrival = api.arrivals[indexPath.row]
        
        cell.displayArrival(arrival)
        
        return cell
        
    }
}

