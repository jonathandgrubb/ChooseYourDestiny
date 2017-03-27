//
//  GitHubClient.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 7/17/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import Foundation

class GitHubClient : NSObject {
    
    // shared session
    var session = URLSession.shared
    
    // TODO: put this in a better place
    var startAtBeginning : Bool?
    var currentChapter : Chapter?
    
    // GET
    @discardableResult func taskForGETMethod(_ method: String, parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // 1. (TODO) Set the parameters
        var params = parameters
        
        // 2/3. Build the URL, Configure the request
        let request = NSMutableURLRequest(url: parseURLFromParameters(params, withPathExtension: method))
        
        // 4. Make the request
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // 5/6. Parse the data and use the data (happens in completion handler)
            ClientCommon.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }) 
        
        // 7. Start the request
        task.resume()
        
        return task
    }

    // Jarrod Parkes - create a URL from parameters
    fileprivate func parseURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Endpoint.APIScheme
        components.host = Endpoint.APIHost
        components.path = Endpoint.APIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> GitHubClient {
        struct Singleton {
            static var sharedInstance = GitHubClient()
        }
        return Singleton.sharedInstance
    }
    
}
