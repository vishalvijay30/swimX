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
            ("10 yards", 10)
        ]
    
    @IBAction func pickSize(_ value: Int) {
        
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
