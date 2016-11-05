//
//  ViewController.swift
//  SwimX
//
//  Created by Anushk Mittal on 10/7/16.
//  Copyright © 2016 Anushk Mittal. All rights reserved.
// .......

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var backgroundImage: UIImageView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
       // locationManager.requestAlwaysAuthorization()
        backgroundImage.image = #imageLiteral(resourceName: "swimming.jpg")
        backgroundImage.sizeToFit()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

