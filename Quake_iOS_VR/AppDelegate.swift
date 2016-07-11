//
//  AppDelegate.swift
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/2/16.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        return true
    }

    func applicationWillResignActive(application: UIApplication)
    {
        if startGame
        {
            gameInterrupted = true
            
            if (host_initialized != qboolean(0))
            {
                Host_Shutdown()
            }
            
            sys_ended = qboolean(1)
        }
    }

    func applicationDidEnterBackground(application: UIApplication)
    {
    }

    func applicationWillEnterForeground(application: UIApplication)
    {
    }

    func applicationDidBecomeActive(application: UIApplication)
    {
    }

    func applicationWillTerminate(application: UIApplication)
    {
    }
}

