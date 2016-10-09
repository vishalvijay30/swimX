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


class StatsTwoController: WKInterfaceController {
    

    @IBOutlet var flipTurnTimeButton: WKInterfaceLabel!
    var motionManager = CMMotionManager()
    var statsOneController = StatsOneController()
    var previousAcceleration: CMAcceleration? = nil
    var timer = Timer()
    var flipTurnTime: Double = 0.0
    var flipTurnTimeArr: [Double] = []
    
    //dummy length variable for now; need to get length of pool from user
    let length = 25.0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //display the current flip turn time
        
        flipTurnTimeButton.setText("\(flipTurnTime)")
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkAccelerationCondition), userInfo: nil, repeats: true) // TODO: invalidate it
        // Configure interface objects here.
    }
    
    func checkAccelerationCondition() {

        if (fabs(statsOneController.getCurrentDistance()-length)<=5.0) {
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
                
            } else { //need help with invalidate condition
                motionManager.stopAccelerometerUpdates()
                flipTurnTimeArr.append(flipTurnTime)
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
        flipTurnTimeButton.setText("\(flipTurnTime)")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
