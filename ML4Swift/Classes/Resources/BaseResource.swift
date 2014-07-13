/**
 *
 * BaseResource.swift
 * ML4Swift
 *
 * Created by Felix Garcia Lainez on 12/07/14
 * Copyright 2014 Felix Garcia Lainez
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

class BaseResource
{
    //KNOWN ISSUE IN APPLE COMPILER
    /**
     * var resourceBaseURL:String{
     *     return ""
     * }
     */
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////  UTILITY METHODS  ///////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /*!
     * Do generic HTTP request
     */
    func doHttpRequestWith(#url: String, method: String, body: String?) -> (statusCode: HTTPStatusCode?, data: NSData?)
    {
        var statusCode: HTTPStatusCode?
        
        var error : NSError?
        var response: NSURLResponse?
        
        var request = NSMutableURLRequest(URL: NSURL.URLWithString(url))
        request.HTTPMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let responseData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        
        if let httpResponse = response as? NSHTTPURLResponse {
            // Work with HTTP response
            statusCode = HTTPStatusCode.fromRaw(httpResponse.statusCode)
        }
        
        return (statusCode, responseData)
    }
    
    func extractResourceIdFrom(data: NSDictionary?) -> String?
    {
        var resourceId: String?
        
        if let dataValue = data {
            if let resourceIdValue = dataValue.objectForKey("resource") as? String {
                resourceId = resourceIdValue.componentsSeparatedByString("/")[1] as String
            }
        }
        
        return resourceId
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////  GENERIC HTTP REQUEST METHODS  ///////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func createResourceWith(#url: String, body: String?) -> (statusCode: HTTPStatusCode?, resourceId: String?, resourceData: NSDictionary?)
    {
        var resourceId: String?
        var resourceData: NSDictionary?
        
        let result = self.doHttpRequestWith(url: url, method: "POST", body: body)
        
        if result.statusCode != nil && result.data != nil && result.statusCode == HTTPStatusCode.HTTP_CREATED {
            resourceData = NSJSONSerialization.JSONObjectWithData(result.data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
            
            resourceId = self.extractResourceIdFrom(resourceData)
        }
        
        return (result.statusCode, resourceId, resourceData)
    }
    
    func updateResourceWith(url: String, body: String?) -> (statusCode: HTTPStatusCode?, data: NSDictionary?)
    {
        var resourceData: NSDictionary?
        
        let result = self.doHttpRequestWith(url: url, method: "PUT", body: body)
        
        if result.statusCode != nil && result.data != nil && result.statusCode == HTTPStatusCode.HTTP_ACCEPTED {
            resourceData = NSJSONSerialization.JSONObjectWithData(result.data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
        }
        
        return (result.statusCode, resourceData)
    }
    
    func deleteResourceWith(url: String) -> (statusCode: HTTPStatusCode?)
    {
        let result = self.doHttpRequestWith(url: url, method: "DELETE", body: nil)
        
        return (result.statusCode)
    }
    
    func resourceWith(url: String) -> (statusCode: HTTPStatusCode?, resourceId: String?, resourceData: NSDictionary?)
    {
        var resourceId: String?
        var resourceData: NSDictionary?
        
        let result = self.doHttpRequestWith(url: url, method: "GET", body: nil)
        
        if result.statusCode != nil && result.data != nil && result.statusCode == HTTPStatusCode.HTTP_OK {
            resourceData = NSJSONSerialization.JSONObjectWithData(result.data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
            
            resourceId = self.extractResourceIdFrom(resourceData)
        }
        
        return (result.statusCode, resourceId, resourceData)
    }
    
    func listResourcesWith(url: String) -> (statusCode: HTTPStatusCode?, resourcesData: NSDictionary?)
    {
        var resourcesData: NSDictionary?
        
        let result = self.doHttpRequestWith(url: url, method: "GET", body: nil)
        
        if result.statusCode != nil && result.data != nil && result.statusCode == HTTPStatusCode.HTTP_OK {
            resourcesData = NSJSONSerialization.JSONObjectWithData(result.data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
        }
        
        return (result.statusCode, resourcesData)
    }
}