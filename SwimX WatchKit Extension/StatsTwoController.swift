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
    
    @IBOutlet var flipTurnTimeButton: WKInterfaceButton!
    var motionManager = CMMotionManager()
    var statsOneController = StatsOneController()
    var previousAcceleration: CMAcceleration? = nil
    var timer = Timer()
    
    //dummy length variable for now; need to get length of pool from user
    let length = 25.0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        motionManager.accelerometerUpdateInterval = 0.1
        if (fabs(statsOneController.getCurrentDistance()-length)<=5.0) {
            //starting updates on current queue for now; not recommended in the future
            
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
                
                self.startTimer(acceleration: accelerometerData!.acceleration)
                
                if(NSError != nil) {
                    print("\(NSError)")
                }
            })
        }
        // Configure interface objects here.
    }
    
    func startTimer(acceleration: CMAcceleration) {
        if (previousAcceleration != nil) {
            
            //very clunky currently; think of a better way to do this
            
            if (((previousAcceleration!.x > 0 && acceleration.x < 0) ||
                (previousAcceleration!.x < 0 && acceleration.x > 0)) ||
                ((previousAcceleration!.y > 0 && acceleration.y < 0) ||
                    (previousAcceleration!.y < 0 && acceleration.y > 0))) {
                
                
                //start timer
                
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(StatsTwoController.checkTime), userInfo: nil, repeats: true)
                //checkTime(prevAcc: previousAcceleration!, currAcc: acceleration)
            }
        } else {
            
            previousAcceleration = acceleration
        }
        
    }
    
    func checkTime(prevAcc: CMAcceleration, currAcc: CMAcceleration) -> Void {
        
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
