//
//  AppDelegate.swift
//  QGTut
//
//  Created by mcmanderson on 5/15/17.
//  Copyright © 2017 mcmanderson. All rights reserved.
//


import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

/*
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}
	*/
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		let mainVC = MainViewController()
		let navigationController = UINavigationController(rootViewController: mainVC)
        navigationController.setToolbarHidden(true,
             animated: false)
		navigationController.toolbar.barTintColor = UIColor.black
		navigationController.toolbar.tintColor = UIColor.black
		//navigationController.navigationBar.barTintColor = UIColor.black
 		//navigationController.navigationBar.tintColor = UIColor.white
		navigationController.navigationBar.barStyle = .blackOpaque
       // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
          window.rootViewController = navigationController
          window.makeKeyAndVisible()
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
//print ("Application will enter foreground")
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//print ("Application did become active")
/*
	let navController = window?.rootViewController as! UINavigationController
	if let nv = navController.visibleViewController as? TreeViewController
		{
		if nv.treeView.previousBounds != nil
			{
			nv.treeView.setNeedsLayout()
			nv.viewDidLayoutSubviews()
			
			} // Only need to run this treeView init stuff if we are returning from already initialized view and maybe changed orientation when running some other app
		}
*/
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

func applicationDidReceiveMemoryWarning(_ application: UIApplication)
	{
	print ("App did receive memory warning: emergency minimizing...")
	}
}

