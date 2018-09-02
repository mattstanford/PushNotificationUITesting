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
    
    func setUp() {
        do {
            try server.start(8080)
            setupPushTokenEndpoint()
        } catch {
            print("Error starting mock server" + error.localizedDescription)
        }
    }
    
    func tearDown() {
        server.stop()
    }
    
    private func setupPushTokenEndpoint() {
        
        let response: ((HttpRequest) -> HttpResponse) = { [weak self] request in
            
            guard let json = self?.getJson(from: request),
                let token = json["deviceToken"] as? String else {
                return HttpResponse.badRequest(nil)
            }
            
            //Save off of the push token once we parse it
            self?.pushToken = token
            
            print("got push token: \(token)")
            
            return HttpResponse.ok(HttpResponseBody.text(""))
        }
        
        server.POST[UITestingConstants.pushEndpoint] = response
        server.PUT[UITestingConstants.pushEndpoint] = response
        server.GET[UITestingConstants.pushEndpoint] = response

    }
    
    private func getJson(from request: HttpRequest) -> JSON? {
        if let json = try? JSONSerialization.jsonObject(with: Data(request.body), options: []) as? JSON {
            return json
        } else {
            return nil
        }
    }
}

