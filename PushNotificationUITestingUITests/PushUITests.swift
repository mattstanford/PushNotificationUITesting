//
//  PushNotificationUITestingUITests.swift
//  PushNotificationUITestingUITests
//
//  Created by Matt Stanford on 9/2/18.
//  Copyright © 2018 locacha. All rights reserved.
//

import XCTest
import Swifter
import NWPusher

class PushUITests: XCTestCase {
    
    var mockServer = MockServer()
    var app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        mockServer.setUp()
        
        continueAfterFailure = false
        app.launch()
        allowPushNotificationsIfNeeded()
    }
    
    override func tearDown() {
        super.tearDown()
        mockServer.tearDown()
    }
    
    func testPushType1() {
        
        waitForElementToAppear(object: app.staticTexts["Push Notification UI Testing"])
        
        //Tap the home button
        XCUIDevice.shared.press(XCUIDevice.Button.home)

        //Trigger a push notification
        triggerPushNotification(withPayload: .pushType1)
        
        //Tap the notification when it appears
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let springBoardNotification = springboard.otherElements["NotificationShortLookView"]
        waitForElementToAppear(object: springBoardNotification)
        springBoardNotification.tap()

        waitForElementToAppear(object: app.staticTexts["Push Notification UI Testing"])
    }
    
    private func triggerPushNotification(withPayload payload: PushNotificationPayload) {
        let uiTestBundle = Bundle(for: PushUITests.self)
        guard let url = uiTestBundle.url(forResource: "pushtesting_sandbox", withExtension: "p12") else {
            XCTFail("Couldn't get push key!")
            return
        }
        
        guard let deviceToken = mockServer.pushToken else {
            XCTFail("Couldn't find device token!")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let pusher = try NWPusher.connect(withPKCS12Data: data, password: "password", environment: .sandbox)
            try pusher.pushPayload(payload.apnsPayload, token: deviceToken, identifier: UInt(arc4random_uniform(UInt32(999))))
        } catch {
            XCTFail("Error connecting to push server.  Check to see if the push certificate is expired or the password is correct!")
            print(error)
        }
    }
    
    private func allowPushNotificationsIfNeeded() {
        addUIInterruptionMonitor(withDescription: "Push Notification Monitor") { alerts -> Bool in
            
            if alerts.buttons["Allow"].exists {
                alerts.buttons["Allow"].tap()
            }
            
            return true
        }
        app.swipeUp()
    }
    
    func waitForElementToAppear(object: Any) {
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: object, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
