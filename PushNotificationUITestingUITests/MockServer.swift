//
//  MockServer.swift
//  PushNotificationUITestingUITests
//
//  Created by Matt Stanford on 9/2/18.
//  Copyright © 2018 locacha. All rights reserved.
//

import Foundation
import Swifter
import NWPusher

typealias JSON = [String: Any]

class MockServer {
    
    var server = HttpServer()
    var pushToken: String?
    
    /*
        Start up the server and configure hadnling of the device token endpoint
    */
    func setUp() {
        do {
            try server.start(8080)
            setupPushTokenEndpoint()
        } catch {
            print("Error starting mock server" + error.localizedDescription)
        }
    }
    
    /*
        Remember to call this to shut down your server when the test ends
    */
    func tearDown() {
        server.stop()
    }
    
    /*
        This configures the mock server to handle the push notification endpoint
     */
    private func setupPushTokenEndpoint() {
        
        let response: ((HttpRequest) -> HttpResponse) = { [weak self] request in
            
            guard let serializedObject = try? JSONSerialization.jsonObject(with: Data(request.body), options: []),
                let json = serializedObject as? JSON,
                let token = json["deviceToken"] as? String else {
                return HttpResponse.badRequest(nil)
            }
            
            //Save off of the push token once we parse it
            self?.pushToken = token
            
            print("got push token: \(token)")
            
            return HttpResponse.ok(HttpResponseBody.text(""))
        }
        
        server.POST[UITestingConstants.pushEndpoint] = response
    }
}

