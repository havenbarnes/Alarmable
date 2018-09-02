//
//  Request.swift
//  Alarmable
//
//  Created by Haven Barnes on 8/10/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import Foundation
import Alamofire

/// A generic url request that adds a layer of abstraction on
/// Alamofire. Sufficient for the use of Alarmable's API
class Request {
    
    enum Endpoint: String {
        case alarm = "alarms/"
    }
    
    var baseUrl = "https://alarmable-server.herokuapp.com/"
        
    var urlParameter = ""
    var method: HTTPMethod
    var endpoint: Endpoint
    var body: Parameters?
    
    init(endpoint: Endpoint, method: HTTPMethod, urlParameter: String = "", body: Parameters? = nil) {
        self.endpoint = endpoint
        self.method = method
        self.urlParameter = urlParameter
        self.body = body
    }
    
    func url() -> URL {
        let urlString = baseUrl + endpoint.rawValue + urlParameter
        print(urlString)
        return URL(string: urlString)!
    }
    
    func send(completion: ((Bool, Error?) -> ())?) {
        Alamofire.request(url(), method: method, parameters: body, encoding: JSONEncoding.default, headers: nil).responseString(completionHandler: {
            result in
            
            guard result.error == nil else {
                print(result.error!)
                completion?(false, result.error)
                return
            }
            
            guard result.data != nil else {
                print("No response from server.")
                completion?(false, nil)
                return
            }
            
            let response = String(data: result.data!,
                                  encoding: String.Encoding.utf8)
            print(response ?? "No response from server.")
            completion?(true, nil)
        })
    }
}
