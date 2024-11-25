//
//  AppDelegate.swift
//  ICMP
//
//  Created by Михаил Конюхов on 09.11.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            window = UIWindow(windowScene: scene)
            window?.rootViewController = ViewController()
            window?.makeKeyAndVisible()
        }
        return true
    }

}

