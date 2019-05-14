//
//  AppDelegate.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 4/21/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // connect to firebase
        FirebaseApp.configure()
        // set nav bar to transparent
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isTranslucent = true
        // use avenir font
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 20)!
        ]
        return true
    }

}

