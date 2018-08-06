//
//  RootViewController.swift
//  
//
//  Created by Blydro Klonk on 8/6/18.
//

import UIKit

class RootViewController: UINavigationController {
    
    var arrivalController: MainCollectionViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public func reloadCollectionView() {
        guard let arrivalController = self.childViewControllers[0] as? MainCollectionViewController else {
            fatalError("Child isn't proper!")
        }
        self.arrivalController = arrivalController
        
        arrivalController.viewDidLoad() //this resets location
        arrivalController.navigationItem.title = "Loading..." //this resets the navigation bar
        DispatchQueue.main.async {
            arrivalController.collectionView?.reloadSections(IndexSet(integer: 0)) //this clears the screen
        }

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
