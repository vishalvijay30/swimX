//
//  StatsOneController.swift
//  SwimX
//
//  Created by Anushk Mittal on 10/8/16.
//  Copyright © 2016 Anushk Mittal. All rights reserved.
//  ...

import WatchKit
import HealthKit
import CoreLocation
import Foundation
import CoreLocation


class StatsOneController: WKInterfaceController, HKWorkoutSessionDelegate, CLLocationManagerDelegate {
    
    var locManager = CLLocationManager()
    var currentSpeed: Double = 0.0
    var currentDistance: Double = 0.0
    @IBOutlet var distanceLabel: WKInterfaceLabel!
    @IBOutlet var speedLabel: WKInterfaceLabel!
    var locPrevious:CLLocation? = nil
    
    @IBOutlet var heartLabel: WKInterfaceLabel!
    @IBOutlet var calsBurned: WKInterfaceLabel!
    
    
    let healthStore = HKHealthStore()

    //State of the app - is the workout activated
    var workoutActive = false
    
    // define the activity type and location
    var session : HKWorkoutSession?
    let heartRateUnit = HKUnit(from: "count/min")
    //var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    var currenQuery : HKQuery?


    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        
        //set up location manager and delegate
        locManager.delegate = self
        
        // core location authorization
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus {
        case .notDetermined:
            locManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse:
            locManager.requestLocation()
            
        case .denied:
            print("denied")
            
        default:
            print("unexpectedText")
        }
        
        
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.startUpdatingLocation()        
    }
    
    @IBAction func exit() {
        
        //finish the current workout
        self.workoutActive = false
        if let workout = self.session {
            healthStore.end(workout)
        }
        
        WKInterfaceController.reloadRootControllers(withNames: ["main"], contexts: nil)
    }
    
    func displayNotAllowed() {
        print("not allowed")
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
        
        // core location authorization 
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus {
        case .notDetermined:
            locManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse:
            locManager.requestLocation()
            
        case .denied:
            print("denied")
            
        default:
            print("unexpectedText")
        }

        
        
        speedLabel.setText("\(currentSpeed)")
        distanceLabel.setText("\(currentDistance)")
        guard HKHealthStore.isHealthDataAvailable() == true else {
            print("not available")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            displayNotAllowed()
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) -> Void in
            if success == false {
                self.displayNotAllowed()
            }
        }
        
        //start a new workout
        self.workoutActive = true
        startWorkout()
        
    }
    
    

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        //<!------ WE MIGHT HAVE TO LEAVE UPDATE LOCATION RUNNING IN THE BACKGROUND IF WE WANT LIVE UPDATES !------>
        //stop updating the location when this view controller is deactivated to conserve battery
        locManager.stopUpdatingLocation()
    }
    
    
    
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            workoutDidStart(date)
        case .ended:
            workoutDidEnd(date)
        default:
            print("Unexpected state \(toState)")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Do nothing for now
        print("Workout error")
    }
    
    
    func workoutDidStart(_ date : Date) {
        if let query = createHeartRateStreamingQuery(date) {
            self.currenQuery = query
            healthStore.execute(query)
        } else {
            print("cannot start")
        }
    }
    
    func workoutDidEnd(_ date : Date) {
        healthStore.stop(self.currenQuery!)
        print("workout ended successfully")
        session = nil
    }

    
    func startWorkout() {
        
        // If we have already started the workout, then do nothing.
        if (session != nil) {
            return
        }
        
        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .baseball //TODO: swimming gives fatal error
        workoutConfiguration.locationType = .outdoor
        
        do {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
            session?.delegate = self
        } catch {
            fatalError("Unable to create the workout session!")
        }
        
        healthStore.start(self.session!)
    }
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate )
        //let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            //guard let newAnchor = newAnchor else {return}
            //self.anchor = newAnchor
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            //self.anchor = newAnchor!
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }

    func updateHeartRate(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        DispatchQueue.main.async {
            guard let sample = heartRateSamples.first else{return}
            let value = sample.quantity.doubleValue(for: self.heartRateUnit)
            print(String(UInt16(value)))
            self.heartLabel.setText(String(UInt16(value)))
            
            // retrieve source from sample
           //let name = sample.sourceRevision.source.name
         //   self.updateDeviceName(name)
           // self.animateHeart()
        }
    }

}
