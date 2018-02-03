//
//  Songs.swift
//  ProjectProtoType2
//
//  Created by Maninder Singh Jheeta on 4/29/17.
//  Copyright © 2017 Maninder Singh Jheeta All rights reserved.
//

import Foundation

class Songs{

    var directoryName = ""
    var currentSong = 0
    var songs=[String]()
    var videos = [String]()
    let songFormat = "mp3"
    
    func evaluateResponse(_ happyness:Int,_ sadness:Int)->String
    {
        
        if happyness > sadness{
            directoryName = "Happy"
        }
        else{
            directoryName = "Sad"
        }
        let audioFilePath = URL (fileURLWithPath: Bundle.main.path(forAuxiliaryExecutable: directoryName)!)
            print(audioFilePath)
            do{
                let songPath = try FileManager.default.contentsOfDirectory(at:audioFilePath, includingPropertiesForKeys: nil,options:.skipsHiddenFiles)
                
                for song in songPath
                {
                    var mySong = song.absoluteString
                    
                    if mySong.contains(".mp3")
                    {
                        let findString = mySong.components(separatedBy: "/")
                        mySong = findString[findString.count-1]
                        
                        mySong = mySong.replacingOccurrences(of: "%20", with: "")
                        mySong = mySong.replacingOccurrences(of: ".mp3", with: "")
                        print(mySong)
                        self.songs.append(mySong)
                    }
                    
                }
            }
            catch{
            }
        
        var directoryNameForVideo =  directoryName+"Vid"
        let videoFilePath = URL (fileURLWithPath: Bundle.main.path(forAuxiliaryExecutable: directoryNameForVideo)!)
        print(audioFilePath)
        do{
            let songPath = try FileManager.default.contentsOfDirectory(at:videoFilePath, includingPropertiesForKeys: nil,options:.skipsHiddenFiles)
            
            for song in songPath
            {
                var mySong = song.absoluteString
                
                if mySong.contains(".mp4")
                {
                    let findString = mySong.components(separatedBy: "/")
                    mySong = findString[findString.count-1]
                    
                    mySong = mySong.replacingOccurrences(of: "%20", with: "")
                    mySong = mySong.replacingOccurrences(of: ".mp4", with: "")
                    print(mySong)
                    self.videos.append(mySong)
                }
            }
        }
        catch{
        }
        return self.directoryName
    }
}
