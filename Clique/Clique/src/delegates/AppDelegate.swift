//
//  AppDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 1/16/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window?.tintColor = UIColor.orange
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        //ask SPTAuth if the URL given is a Spotify authentication callback
        if (SPTAuth.defaultInstance().canHandle(url)) {
            SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) -> Void in
                if (error != nil) {
                    print("appdelegate: *** Auth error: \(String(describing: error))")
                    return
                }
                Spotify.authorization = session?.accessToken ?? ""
                print("appdelegate: spotify authenticated successfully with token", Spotify.authorization)
                Spotify.player?.login(with: session, callback: { _ in })
                spotifysession = session
                Settings.spotify = true
            })
            
            return true
        }
        
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        //q.manager?.stop()
        q.timer = nil
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        q.timer = nil
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        np.refresh()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //np.refresh()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
        
        gm?.stop(listening: ())
        gm?.stop(sharing: ())
    }

}

