//
//  StatsOneController.swift
//  SwimX
//
//  Created by Anushk Mittal on 10/8/16.
//  Copyright © 2016 Anushk Mittal. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

class StatsOneController: WKInterfaceController, CLLocationManagerDelegate {
    
    var locManager = CLLocationManager()
    var currentSpeed: Double = 0.0
    var currentDistance: Double = 0.0
    @IBOutlet var distanceLabel: WKInterfaceLabel!
    @IBOutlet var speedLabel: WKInterfaceLabel!
    var locPrevious:CLLocation? = nil
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //consider moving to willActivate() method since only needed there
        //set current speed
        speedLabel.setText("\(currentSpeed)")
        distanceLabel.setText("\(currentDistance)")
        
        //set up location manager and delegate
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.startUpdatingLocation()        
    }
    

    @IBAction func exit() {
        
        WKInterfaceController.reloadRootControllers(withNames: ["main"], contexts: nil)
    }
    


    //If authorization status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        
        switch status {
        case .notDetermined:
            locManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse:
            locManager.startUpdatingLocation()
            
        //not sure if this is needed when .authorizedInUse is available
        case .authorizedAlways:
            locManager.startUpdatingLocation()
            
        case .denied:
            locManager.stopUpdatingLocation()
            speedLabel.setText("Location Permission not granted!")
            
        default:
            speedLabel.setText("Location Permission not granted!")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("\(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[locations.count-1]
        updateSpeed(location: currentLocation)
        updateDistance(location: currentLocation)
    }
    
    func updateSpeed(location:CLLocation) -> Void {
        currentSpeed = location.speed
        speedLabel.setText("\(currentSpeed)")
        
    }
    
    func updateDistance(location:CLLocation) -> Void {
        if locPrevious != nil {
            currentDistance += location.distance(from: locPrevious!)
            distanceLabel.setText("\(currentDistance)")
            locPrevious = location
        } else {
            locPrevious = location
        }
    }
    
    func getCurrentSpeed() -> Double {
        return currentSpeed
    }
    
    func getCurrentDistance() -> Double {
        return currentDistance
    }
    

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        //<!------ WE MIGHT HAVE TO LEAVE UPDATE LOCATION RUNNING IN THE BACKGROUND IF WE WANT LIVE UPDATES !------>
        //stop updating the location when this view controller is deactivated to conserve battery
        locManager.stopUpdatingLocation()
    }

}
