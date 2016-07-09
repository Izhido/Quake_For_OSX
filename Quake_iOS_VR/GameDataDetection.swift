//
//  GameDataDetection.swift
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 7/9/16.
//
//

import UIKit

class GameDataDetection: NSObject
{
    static var sharewarePresent = false

    static var registeredPresent = false
    
    static var missionPack1Present = false
    
    static var missionPack2Present = false
    
    static func detect()
    {
        let documentsDir = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true).path!
        
        let id1pak0Attributes : NSDictionary? = try? NSFileManager.defaultManager().attributesOfItemAtPath("\(documentsDir)/id1/pak0.pak")
        let id1pak1Attributes : NSDictionary? = try? NSFileManager.defaultManager().attributesOfItemAtPath("\(documentsDir)/id1/pak1.pak")
        
        let hipnoticpak0Attributes : NSDictionary? = try? NSFileManager.defaultManager().attributesOfItemAtPath("\(documentsDir)/hipnotic/pak0.pak")
        
        let roguepak0Attributes : NSDictionary? = try? NSFileManager.defaultManager().attributesOfItemAtPath("\(documentsDir)/rogue/pak0.pak")
        
        sharewarePresent = false
        registeredPresent = false
        missionPack1Present = false
        missionPack2Present = false
        
        if id1pak0Attributes != nil && id1pak0Attributes!.fileSize() == 18689235
        {
            if id1pak1Attributes != nil && id1pak1Attributes!.fileSize() == 34257856
            {
                registeredPresent = true
                
                if hipnoticpak0Attributes != nil && hipnoticpak0Attributes!.fileSize() == 35527205
                {
                    missionPack1Present = true
                }
                
                if roguepak0Attributes != nil && roguepak0Attributes!.fileSize() == 37875279
                {
                    missionPack2Present = true
                }
            }
            else
            {
                sharewarePresent = true
            }
        }
    }
}
