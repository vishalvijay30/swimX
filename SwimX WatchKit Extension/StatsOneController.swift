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



class StatsOneController: WKInterfaceController, HKWorkoutSessionDelegate, CLLocationManagerDelegate {
    
    var locManager = CLLocationManager()
    var currentSpeed: Double = 0.0
    var currentDistance: Double = 0.0
    var weight_value: Double = 0.0
    var calories: Double = 0.0
    var timeElapsed: Int = 0 // number of seconds since the start of session
    var startTime: Date! // date object for start time of session
    @IBOutlet var timeLabel: WKInterfaceTimer!
    @IBOutlet var calLabel: WKInterfaceLabel!
    
    @IBOutlet var distanceLabel: WKInterfaceLabel!
    @IBOutlet var speedLabel: WKInterfaceLabel!
    var locPrevious:CLLocation? = nil
    
    @IBOutlet var heartLabel: WKInterfaceLabel!
    
    
    let healthStore = HKHealthStore()
    var weight : HKQuantitySample?

    //State of the app - is the workout activated
    var workoutActive = false
    
    // define the activity type and location
    var session : HKWorkoutSession?
    let heartRateUnit = HKUnit(from: "count/min")
    //var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    var currenQuery : HKQuery?


    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        startTime = Date()
        
        timeLabel.setDate(Date()) //Set Display Timer date to current time (invoked once)
        
        print(CLLocationManager.authorizationStatus())
        
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
        print(CLLocationManager.authorizationStatus())
    }
    
    @IBAction func exit() {
        
        // timer stop
        timeLabel.stop()
        
        //finish the current workout
        self.workoutActive = false
        if let workout = self.session {
            healthStore.end(workout)
        }
        locManager.stopUpdatingLocation()
        
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
        speedLabel.setText("\(currentSpeed) m/s")
        
    }
    
    func updateDistance(location:CLLocation) -> Void {
        if locPrevious != nil {
            currentDistance += location.distance(from: locPrevious!)
            distanceLabel.setText("\(currentDistance) m")
            locPrevious = location
        } else {
            locPrevious = location
        }
    }
    
    func getCurrentSpeed() -> Double {
        //round to 2 decimal places
        return round(100 * currentSpeed) / 100
    }
    
    func getCurrentDistance() -> Double {
        return round(100 * currentDistance) / 100
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.getWeight()
        
        timeLabel.start() // Start Display timer

        print(CLLocationManager.authorizationStatus())
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

        //locManager.requestWhenInUseAuthorization()
        

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
        
        print(CLLocationManager.authorizationStatus())
        
        // calories burned calculation
        
        timeElapsed = Int(-1*(startTime.timeIntervalSinceNow))
        calories = 3.32*weight_value*(Double(timeElapsed)/(60*60))
        calLabel.setText(String(calories.roundTo(places: 1))+" cals")
        print(calories)
        print(calories.roundTo(places: 1))
        
    }
    
    

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
    
    /** Get last recorded weight */
    func getWeight() {
        
        print("TODO: get Weight")
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        self.readMostRecentSample(sampleType: sampleType!, completion: { (mostRecentWeight, error) -> Void in
            
            if( error != nil ) {
                print("Error reading weight from HealthKit Store: \(error?.localizedDescription)")
                return;
            }
            
            var weightLocalizedString = ""
            
            self.weight = mostRecentWeight as? HKQuantitySample;
            if let kilograms = self.weight?.quantity.doubleValue(for: HKUnit.pound()) {
                let weightFormatter = MassFormatter()
                weightFormatter.isForPersonMassUse = true;
                weightLocalizedString = weightFormatter.string(fromKilograms: kilograms)
                self.weight_value = kilograms
                print(self.weight_value)
                print(kilograms)
            }
            
            
            DispatchQueue.main.async(execute: { () -> Void in
                print("first print")
                print(weightLocalizedString)
                print("second print")
                
                //self.weight_value = Double(weightLocalizedString)!
                
            })
        })
        
    }
    
    /** Common method to execute query */
    func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample?, NSError?) -> Void)!)
    {
        
        // Predicate
        let past = Date.distantPast as Date
        let now   = Date()
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: past as Date, end:now as Date, options: [])
        
        // Sort descriptor to return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        
        // Limit the number of samples returned by the query to just 1 (the most recent)
        let limit = 1
        
        // Query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            
            if error != nil  {
                print(error)
            }
            
            // Get the first sample
            let mostRecentSample = results?.first as? HKQuantitySample
            
            // Execute the completion closure
            if completion != nil {
                completion(mostRecentSample,nil)
            }
        }
        // Execute the Query
        self.healthStore.execute(sampleQuery)
    }

}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
