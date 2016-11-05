//
//  InterfaceController.swift
//  SwimX WatchKit Extension
//
//  Created by Anushk Mittal on 10/7/16.
//  Copyright © 2016 Anushk Mittal. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity



class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("something happened")
    }

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if (WCSession.isSupported()) {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
            NSLog("yes supported")
        }
        
        
        if WCSession.default().isReachable {
            
            print("WCSession is reachable")
            let messageDict = ["Request": "iPhone Can You Give Me The Array"]
            WCSession.default().sendMessage(messageDict, replyHandler: { (replyDict) -> Void in
                print("replyDict \(replyDict)")
                }, errorHandler: { (error) -> Void in
                    print(error)
                    print("there's an error")
            })
        }
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
