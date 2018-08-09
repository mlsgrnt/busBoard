
//
//  ViewController.swift
//  busBoard
//
//  Created by Blydro Klonk on 8/6/18.
//  Copyright © 2018 Blydro Klonk. All rights reserved.
//

import UIKit
import PeekPop

class AllDeparturesCollectionViewController: UICollectionViewController, PeekPopPreviewingDelegate {

    //, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //Outlets
    @IBOutlet var mainCollectionView: UICollectionView!
    
    var peekPop: PeekPop?
    var timer: Timer?
    
    let api = API.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        if let previewViewController = storyboard.instantiateViewController(withIdentifier: "arrivalDetail") as? arrivalDetailViewController {
            if let indexPath = collectionView!.indexPathForItem(at: location) {
                let arrival = api.allArrivals[indexPath.item]
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
    
    //MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (self.view.bounds.size.width - 10)
        return CGSize(width: size, height: size)
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return api.allArrivals.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "arrivalCollectionViewCell", for: indexPath) as! arrivalCollectionViewCell
        let arrival = api.allArrivals[indexPath.row]
        
        cell.displayArrival(arrival)
        
        return cell
        
    }
    
    //MARK: - NavBarButtons
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

