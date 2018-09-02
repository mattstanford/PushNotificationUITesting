//
//  AppDelegate.swift
//  PushNotificationUITesting
//
//  Created by Matt Stanford on 9/2/18.
//  Copyright © 2018 locacha. All rights reserved.
//

import UIKit
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        registerForRemoteNotification()
        
        return true
    }

    private func registerForRemoteNotification() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { _, error in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    private func sendPushTokenToServer(token: String) {
        // server endpoint
       // let endpoint = "https://app.stickerkit.io/userEvent/v1/\(user.projectID)"
        let endpoint = "http://localhost:8080\(UITestingConstants.pushEndpoint)"
        
        guard let endpointUrl = URL(string: endpoint) else {
            return
        }
        
        //Make JSON to send to send to server
        var json = [String:Any]()
        json[UITestingConstants.pushTokenKey] = token
        
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return
        }
            
        var request = URLRequest(url: endpointUrl)
        request.httpMethod = "POST"
        request.httpBody = data
     //   request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      //  request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
        
        print("sent token: \(token)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("got device token: \(token)")
        sendPushTokenToServer(token: token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }

}

