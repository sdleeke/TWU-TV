//
//  AppDelegate.swift
//  TWU TV
//
//  Created by Steve Leeke on 6/12/17.
//  Copyright © 2017 Countryside Bible Church. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //        print("application:didFinishLaunchingWithOptions")
        
        // Override point for customization after application launch.
        
        globals = Globals()
        
        globals.addAccessoryEvents()
        
        startAudio()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if (globals.mediaPlayer.rate == 0) {
            //It is paused, possibly not by us, but by the system
            if globals.mediaPlayer.isPlaying {
                globals.mediaPlayer.pause()
            }
        }
        
        if (globals.mediaPlayer.rate != 0) {
            if globals.mediaPlayer.isPaused {
                globals.mediaPlayer.play()
            }
        }
        
        globals.setupPlayingInfoCenter()
        
        DispatchQueue.main.async(execute: { () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.SERIES_UPDATE_UI), object: nil)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.SERMON_UPDATE_PLAY_PAUSE), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.SERMON_UPDATE_PLAYING_PAUSED), object: nil)
        })
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

