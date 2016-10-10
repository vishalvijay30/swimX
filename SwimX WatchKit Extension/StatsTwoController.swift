//
//  StatsTwoController.swift
//  SwimX
//
//  Created by Anushk Mittal on 10/8/16.
//  Copyright © 2016 Anushk Mittal. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion


class StatsTwoController: WKInterfaceController, WorkoutManagerDelegate {
    

    @IBOutlet var strokeRateLabel: WKInterfaceLabel!
    @IBOutlet var scPerLapLabel: WKInterfaceLabel!
    @IBOutlet var flipTurnTimeButton: WKInterfaceLabel!
    var motionManager = CMMotionManager()
    var statsOneController = StatsOneController()
    var previousAcceleration: CMAcceleration? = nil
    var timer = Timer()
    var flipTurnTime: Double = 0.0
    var flipTurnTimeArr: [Double] = []
    let workoutManager = WorkoutManager()
    var active:Bool = false
    var forehandCount:Int = 0
    var backhandCount:Int = 0
    var totalNumStrokes:Int = 0
    
    //dummy length variable for now; need to get length of pool from user
    let length = 25.0
    
    override func awake(withContext context: Any?) {
        //print(motionManager.)
        super.awake(withContext: context)
        workoutManager.delegate = self
        workoutManager.startWorkout() //need to stop workout somewhere
        //display the current flip turn time
        if (flipTurnTimeArr.count>0) {
            flipTurnTimeButton.setText("\(flipTurnTimeArr[flipTurnTimeArr.count-1])")
        } else {
            flipTurnTimeButton.setText("0.0")
        }
        scPerLapLabel.setText("\(getStrokesPerLap())")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkAccelerationCondition), userInfo: nil, repeats: true) // TODO: invalidate it
        // Configure interface objects here.
    }
    
    func checkAccelerationCondition() {

        if (fabs(statsOneController.getCurrentDistance().truncatingRemainder(dividingBy: length))<=5.0) {
            //starting updates on current queue for now; not recommended in the future
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
                self.startTimer(acceleration: accelerometerData!.acceleration)
                
                if(NSError != nil) {
                    print("\(NSError)")
                }
            })
        }
    }
    
    func startTimer(acceleration: CMAcceleration) {
        if (previousAcceleration != nil) {
            
            //very clunky currently; think of a better way to do this
            
            if (((previousAcceleration!.x > 0 && acceleration.x < 0) ||
                (previousAcceleration!.x < 0 && acceleration.x > 0)) ||
                ((previousAcceleration!.y > 0 && acceleration.y < 0) ||
                    (previousAcceleration!.y < 0 && acceleration.y > 0))) {
                
                
                //start timer
                
                //timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(StatsTwoController.updateTime), userInfo: nil, repeats: true)
                self.updateTime()
                
            } else { 
                motionManager.stopAccelerometerUpdates()
                flipTurnTimeArr.append(flipTurnTime)
                flipTurnTimeButton.setText("\(flipTurnTimeArr[flipTurnTimeArr.count-1])")
                flipTurnTime = 0.0
            }
        } else {
            
            previousAcceleration = acceleration
        }
        
        previousAcceleration = acceleration
        
    }
    
    func getFlipTurnTimeArr() -> [Double] {
        return flipTurnTimeArr
    }
    
    func getAverageFlipTurnTime() -> Double {
        var total: Double = 0.0
        for i in flipTurnTimeArr {
            total += i
        }
        return total/(Double(getAverageFlipTurnTime()))
    }
    
    func updateTime() -> Void {
        //shows instantaneous or last flip turn time while active
        //we must show average when session ends
        flipTurnTime += 0.1
        //flipTurnTimeButton.setText("\(flipTurnTime)")
    }
    
    
    //code for the stroke
    // MARK: WorkoutManagerDelegate
    
    func didUpdateForehandSwingCount(_ manager: WorkoutManager, forehandCount: Int) {
        /// Serialize the property access and UI updates on the main queue.
        DispatchQueue.main.async {
            self.forehandCount = forehandCount
            self.updateStrokeCount()
        }
    }
    
    func didUpdateBackhandSwingCount(_ manager: WorkoutManager, backhandCount: Int) {
        /// Serialize the property access and UI updates on the main queue.
        DispatchQueue.main.async {
            self.backhandCount = backhandCount
            self.updateStrokeCount()
            
        }
    }
    
    func updateStrokeCount() -> Void {
        if active {
            totalNumStrokes += 1
            self.updateLabels()
        }
    }
    
    func getNumStrokes() -> Int {
        return totalNumStrokes
    }
    
    func getStrokesPerLap() -> Double {
        //creating a new instance of StatsThreeController should updata numLaps
        let s3c = StatsThreeController()
        return (Double(totalNumStrokes)) / (Double(s3c.getNumLaps()))
    }
    
    func getStrokeRate() -> Double {
        let s1c = StatsOneController()
        let time = s1c.getCurrentSpeed() / s1c.getCurrentDistance()
        return (Double(totalNumStrokes)) / (Double(time))
    }
    
    func getMetersPerStroke() -> Double {
        let s1c = StatsOneController()
        return (Double(s1c.getCurrentDistance())) / (Double(totalNumStrokes))
    }
    
    
    //update the labels here
    func updateLabels() -> Void {
        let statsThreeController = StatsThreeController()
        statsThreeController.getMetersPerStrokeLabel().setText("\(getMetersPerStroke())")
        scPerLapLabel.setText("\(getStrokesPerLap())")
        strokeRateLabel.setText("\(getStrokeRate())")
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        active = true
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        active = false
    }

}
