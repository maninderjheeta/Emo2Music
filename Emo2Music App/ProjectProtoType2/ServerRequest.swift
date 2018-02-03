//
//  ServerRequest.swift
//  ProjectProtoType2
//
//  Created by Maninder Singh Jheeta on 4/29/17.
//  Copyright © 2017 Maninder Singh Jheeta All rights reserved.
//

import Foundation

class ServerRequest
{
    let CLIENTIDVALUE = "e34a1b66bcea4554b09469d572448b40"
    let APPLICATIONKEYVALUE = "a2c9a84d04ac42569c92827da8e908ad"
    let REQUESTURL = "http://api.sightcorp.com/api/detect/"
    let CLIENTIDKEY = "client_id"
    let APPLICATIONKEY = "app_key"
    
    func sendRequest(_ requestMethod:String,_ imageData:Data) -> Data
    {
        let myUrl = NSURL(string :REQUESTURL)
        var responseData = Data()
        
        let (data,response,error) = URLSession.shared.synchronousDataTask(with: myUrl as! URL, imageData: imageData)
        print (error)
        responseData = data!
       return responseData
    }
}
extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
extension URLSession {
    func synchronousDataTask(with url: URL, imageData: Data) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        let param = ["app_key":"a2c9a84d04ac42569c92827da8e908ad","client_id":"e34a1b66bcea4554b09469d572448b40"]
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)",forHTTPHeaderField:"Content-Type")
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey:"img", imageDataKey: imageData as NSData, boundary: boundary) as Data
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: request as URLRequest) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "user-profile.jpg"
        let mimetype = "image/jpg"
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        body.appendString(string: "--\(boundary)--\r\n")
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}
