//
//  OlympicTypeController.swift
//  SwimX
//
//  Created by Anushk Mittal on 10/8/16.
//  Copyright © 2016 Anushk Mittal. All rights reserved.
//

import WatchKit
import Foundation


class OlympicTypeController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    
    @IBAction func longType() {
        UserDefaults.standard.set(54.68, forKey: "swimLength")
        WKInterfaceController.reloadRootControllers(withNames: ["statsOne", "statsTwo", "statsThree"], contexts: nil)
    }
    
    @IBAction func shortType() {
        UserDefaults.standard.set(27.34, forKey: "swimLength")
        WKInterfaceController.reloadRootControllers(withNames: ["statsOne", "statsTwo", "statsThree"], contexts: nil)
    }
    

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
