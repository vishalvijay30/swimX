//
//  CustomTypeController.swift
//  SwimX
//
//  Created by Anushk Mittal on 10/8/16.
//  Copyright © 2016 Anushk Mittal. All rights reserved.
//

import WatchKit
import Foundation


class CustomTypeController: WKInterfaceController {
    
    @IBOutlet var selectPicker: WKInterfacePicker!
    
    
    var sizeList: [(String, Int)] =
        [
            ("5 yards", 5),
            ("10 yards", 10),
            ("15 yards", 15),
            ("20 yards", 20),
            ("25 yards", 25),
            ("30 yards", 30),
            ("35 yards", 35),
            ("40 yards", 40),
            ("45 yards", 45),
            ("50 yards", 50),
            ("55 yards", 55),
            ("60 yards", 60),
            ("65 yards", 65),
            ("70 yards", 70),
            ("75 yards", 75),
            ("80 yards", 80),
            ("85 yards", 85),
            ("90 yards", 90),
            ("95 yards", 95),
            ("100 yards", 100)
        ]
    
    @IBAction func pickSize(_ value: Int) {
        UserDefaults.standard.set(Double(sizeList[value].1), forKey: "swimLength")
      //  let num = UserDefaults.standard.integer(forKey: "musicName")
        NSLog("Size Picker: \(sizeList[value].0) selected with value \(sizeList[value].1)")

    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // to display the pool sizes
        
        let pickerItems: [WKPickerItem] = sizeList.map {
            let pickerItem = WKPickerItem()
            pickerItem.title = $0.0
            pickerItem.caption = $0.0
            return pickerItem
        }
        selectPicker.setItems(pickerItems)
    }
    
    
    
    
    @IBAction func swim() {
        
        WKInterfaceController.reloadRootControllers(withNames: ["statsOne", "statsTwo", "statsThree"], contexts: nil)
        
    }
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
