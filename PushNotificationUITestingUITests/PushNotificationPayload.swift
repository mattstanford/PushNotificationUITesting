//
//  PushNotificationPayload.swift
//  PushNotificationUITestingUITests
//
//  Created by Matt Stanford on 9/2/18.
//  Copyright © 2018 locacha. All rights reserved.
//

import Foundation

enum PushNotificationPayload: String {
    case pushType1 = "This is one type of push notification"
    case pushType2 = "This is another type of push notification"
    
    var apnsPayload: String {
        return "{\"aps\":{\"alert\":\"" + self.rawValue + "\", \"badge\":1}}"
    }
}
