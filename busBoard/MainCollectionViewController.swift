
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
    @IBOutlet weak var allDeparturesButton: UIBarButtonItem!
    
    var peekPop: PeekPop?
    let locationManager = CLLocationManager()
    var timer: Timer?
    var sb: UIStoryboard?
    
    let api = API.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide all departures button until we're all loaded
        //not the best way to do it because you can still click on it
        //but it's good enough for now
        //TODO:
        allDeparturesButton.title = ""
        
        //get storyboard to load view from
        self.sb = UIStoryboard(name:"Main", bundle:nil)
        
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
        
        //keep all values up to date
        //this will result in some now-trash at the top but based on the use case for this app that isn't a big deal
        self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [] _ in
            self.collectionView?.reloadData()
        }
        
        //setup peekpop
        peekPop = PeekPop(viewController: self)
        peekPop?.registerForPreviewingWithDelegate(self, sourceView: collectionView!)
    }
    
    //MARK: - peekpop stuff
    func previewingContext(_ previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let previewViewController = self.sb!.instantiateViewController(withIdentifier: "arrivalDetail") as? arrivalDetailViewController {
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
        
    //MARK: - Location Stuff
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        fatalError("location error: \(error)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        api.getArrivals(longitude: location.longitude, latitude: location.latitude, completion: {
            DispatchQueue.main.async {
                self.navigationItem.title = self.api.nearestStationName
                //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                //SIMULATOR STUFF!!!!!!!!!!!
                if (TARGET_OS_SIMULATOR != 0) {
                    //simulator needs fake compass data
                    self.api.filterArrivalsByCompassDirection(direction: 0, completion: {
                        DispatchQueue.main.async {
                            if(self.allDeparturesButton.title == "") {
                                self.allDeparturesButton.title = "All"
                            }
                            self.collectionView?.reloadSections(IndexSet(integer: 0))
                        }
                    })
                    self.api.filterArrivalsByCompassDirection(direction: 1, completion: {
                        DispatchQueue.main.async {
                            if(self.allDeparturesButton.title == "") {
                                self.allDeparturesButton.title = "All"
                            }
                            self.collectionView?.reloadSections(IndexSet(integer: 0))
                        }
                    })
                    self.api.filterArrivalsByCompassDirection(direction: 2, completion: {
                        DispatchQueue.main.async {
                            if(self.allDeparturesButton.title == "") {
                                self.allDeparturesButton.title = "All"
                            }
                            self.collectionView?.reloadSections(IndexSet(integer: 0))
                        }
                    })
                }
                //END OF SIMULATOR STUFF!!!!!!!!
                //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
            }
        })
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        locationManager.headingFilter = 1 //once we get the first heading, decrease the accuracy
        api.filterArrivalsByCompassDirection(direction: Double(newHeading.magneticHeading), completion: {
            DispatchQueue.main.async {
                if(self.allDeparturesButton.title == "") {
                    self.allDeparturesButton.title = "All"
                }
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

