//
//  SwimTypeController.swift
//  SwimX
//
//  Created by Anushk Mittal on 10/8/16.
//  Copyright © 2016 Anushk Mittal. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit


class SwimTypeController: WKInterfaceController {
    
    let healthStore = HKHealthStore()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        /* Requesting HealthKit authorization*/
        guard HKHealthStore.isHealthDataAvailable() == true else {
            print("not available")
            return
        }
        
        let typestoRead = Set([
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
            ])
        
        self.healthStore.requestAuthorization(toShare: nil, read: typestoRead) { (success, error) -> Void in
            if success == false {
                NSLog(" Display not allowed")
            }
        }

    }
    
    @IBAction func openSwim() {
        
        WKInterfaceController.reloadRootControllers(withNames: ["statsOne"], contexts: nil)
        
    }
    
    

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
