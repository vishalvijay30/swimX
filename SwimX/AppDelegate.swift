//
//  AppDelegate.swift
//  SwimX
//
//  Created by Anushk Mittal on 10/7/16.
//  Copyright © 2016 Anushk Mittal. All rights reserved.
// ....

import UIKit
import HealthKit
import WatchConnectivity
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate, CLLocationManagerDelegate {

    let healthStore = HKHealthStore()
    var window: UIWindow?
    let locationManager = CLLocationManager()



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        if (WCSession.isSupported())  {
            
            let session = WCSession.default()
            session.delegate = self
            session.activate()
            
            if session.isPaired != true {
                print("Apple Watch is not paired")
            }
            if session.isWatchAppInstalled != true {
                print("WatchKit app is not installed")
            }
            
        }
        else {
            
            print("WatchConnectivity is not supported on this device")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // HealthKit Authorization from  Watch
    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        
        self.healthStore.handleAuthorizationForExtension { success, error in
            
        }
    }

    
    
    // Watch Connectivity
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == WCSessionActivationState.activated {
            NSLog("Activated")
        }
        
        if activationState == WCSessionActivationState.inactive {
            NSLog("Inactive")
        }
        
        if activationState == WCSessionActivationState.notActivated {
            NSLog("NotActivated")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        NSLog("sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        NSLog("sessionDidDeactivate")
        
        // Begin the activation process for the new Apple Watch.
        WCSession.default().activate()
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        print("Just received a message from the watch.")
        
        // do stuff here after receiving message from the watch
        // since watch connectivity is only used for getting location access
        // we are good to go
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        
        
        print(message["Request"])
        
        if ((message["Request"] as? String) == "iPhone Can You Give Me The Array")
        {
            let applicationData = ["Array":["One1", "Two", "Three"]]
            print(1234)
            replyHandler(applicationData as [String : AnyObject])
            
        }
        
        /*
         if (((message["Request"] as? String)) != nil) {
         
         for (IntOne, IntTwo) in message {
         //    print("\(IntOne): \(IntTwo)")
         //    print("the music number received is\(IntTwo)")
         let applicationData = ["Reply":[String(IntOne), String(IntTwo), "Returned"]]
         //     musicNumber = Int(IntTwo as! NSNumber)
         self.play()
         replyHandler(applicationData)
         NSLog("yes, we did replied!")
         }
         
         }
         */
    }
    /*
    func session(_ session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void)
*/

}

