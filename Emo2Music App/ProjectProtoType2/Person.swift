//
//  Person.swift
//  ProjectProtoType2
//
//  Created by Maninder Singh Jheeta on 4/29/17.
//  Copyright © 2017 Junaid Azhar Shaikh. All rights reserved.
//

import Foundation

class Person{
    
    var happinessCount : Int = 0
    var sadnessCount : Int = 0
    
    init()
    {
        happinessCount = 0
        sadnessCount = 0
    }
    func getFeeling(_ responseData:Data?)->Bool
    {
        var success : Bool = true
        if let content = responseData
        {
            
            do{
                let json = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                print(json)
                
                let mydata = json["persons"] as? [[String:Any]]
                if mydata!.count >  0 {
                    for person in mydata!
                    {
                        if person["expressions"] != nil
                        {
                            if let exp = person["expressions"] as? [String:Any]
                            {
                                if let happiness = exp["happiness"] as? [String:Any]
                                {
                                    happinessCount = happiness["value"]! as! Int
                                }
                                if let sadness = exp["sadness"] as? [String:Any]
                                {
                                    sadnessCount = sadness["value"]! as! Int
                                }
                            }
                        }
                        else{
                                success = false
                        }
                    }
                }
                else {
                        success = false
                }
            }
            catch{}
        }
        return success
    }
    
    func getHappinessCount()->Int{
        return happinessCount
    }
    func getSadnessCount()->Int{
        return sadnessCount
    }
}
