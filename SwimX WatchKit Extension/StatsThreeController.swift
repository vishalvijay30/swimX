//
//  StatsThreeController.swift
//  SwimX
//
//  Created by Anushk Mittal on 10/8/16.
//  Copyright © 2016 Anushk Mittal. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation
import CoreMotion

class StatsThreeController: WKInterfaceController, CLLocationManagerDelegate {
    
    var locManager = CLLocationManager()
    var numLaps: Int = 0
    var initialDirection:Double = 0.0
    @IBOutlet var lapsButtonLabel: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //set the current number of laps
        lapsButtonLabel.setTitle("\(numLaps)")
        
        
        //Configure locationManager and set up delegate
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.startUpdatingLocation() //Stop updating location when didDeactivate()
        initialDirection = locManager.location!.course //doubtful; think about better way
        
        
    }
    
    //If authorization status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        
        switch status {
        case .notDetermined:
            locManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse:
            initialDirection = locManager.location!.course
            locManager.startUpdatingLocation()
            
        //not sure if this is needed when .authorizedInUse is available
        case .authorizedAlways:
            initialDirection = locManager.location!.course
            locManager.startUpdatingLocation()
            
        case .denied:
            locManager.stopUpdatingLocation()
            lapsButtonLabel.setTitle("Location Permission not granted!")
            
        default:
            lapsButtonLabel.setTitle("Permission not granted!")
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("\(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation:CLLocation = locations[locations.count-1]
        incrementNumLaps(location: latestLocation)
    }
    
    func incrementNumLaps(location: CLLocation) -> Void {
        //checking if course is within 10 degrees of 180 degrees required for complete about turn
        //accounting for both 90 degree turn and 180 degree turn
        
        //!---think about whether lap might accidentally get incremented during turn---!
        if (fabs(location.course-180-initialDirection)<=10 ||
            fabs(location.course-90-initialDirection)<=10) {
            
            numLaps+=1
            lapsButtonLabel.setTitle("\(numLaps)")
        }
    }
    
    func getNumLaps() -> Int {
        return numLaps
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
