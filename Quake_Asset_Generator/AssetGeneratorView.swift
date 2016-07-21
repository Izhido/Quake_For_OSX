//
//  AssetGeneratorView.swift
//  Quake_Asset_Generator
//
//  Created by Heriberto Delgado on 7/11/16.
//
//

import AppKit

class AssetGeneratorView: NSView
{
    var assetType : AssetType = .None
    
    var level : CGFloat = 0.0
    
    var pointSize : CGFloat = 0.0
    
    var preview = false
    
    var generate = false
    
    func nextPointSize() -> CGFloat
    {
        if pointSize == 1024.0
        {
            return 180.0
        }
        if pointSize == 180.0
        {
            return 152.0
        }
        else if pointSize == 152.0
        {
            return 120.0
        }
        else if pointSize == 120.0
        {
            return 87.0
        }
        else if pointSize == 87.0
        {
            return 80.0
        }
        else if pointSize == 80.0
        {
            return 76.0
        }
        else if pointSize == 76.0
        {
            return 58.0
        }
        else if pointSize == 58.0
        {
            return 40.0
        }
        else if pointSize == 40.0
        {
            return 29.0
        }
        else
        {
            return 0.0
        }
    }
    
    override func drawRect(dirtyRect: NSRect)
    {
        super.drawRect(dirtyRect)

        let context = NSGraphicsContext.currentContext()!.CGContext
        
        if assetType == .Icon
        {
            if pointSize > 0.0
            {
                let borderSize = pointSize / NSScreen.mainScreen()!.backingScaleFactor
                
                let border = CGRectMake(0.0, 1024.0 - borderSize, borderSize, borderSize)
                
                CGContextSetFillColorWithColor(context, NSColor(red: 101.0 / 255.0, green: 84.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0).CGColor)
                
                CGContextAddRect(context, border)
                
                CGContextFillPath(context)
                
                CGContextScaleCTM(context, 1.0, 2.0)
                
                let fontSize = borderSize
                
                let bigFont = NSFont.systemFontOfSize(fontSize / 2.0)
                
                var text = NSString(string: "S")
                
                var textAttributes = [ NSFontAttributeName : bigFont , NSForegroundColorAttributeName : NSColor(red: 1.0, green: 200.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0) ]
                
                var textSize = text.sizeWithAttributes(textAttributes)
                
                var textLocation = NSMakePoint(borderSize * 27.5 / 100.0 - textSize.width / 2.0, (1024.0 - textSize.height - borderSize * 77.5 / 100.0 + textSize.height / 2.0) / 2.0)
                
                text.drawAtPoint(textLocation, withAttributes: textAttributes)
                
                let smallFont = NSFont.systemFontOfSize(fontSize / 5.0)
                
                text = NSString(string: "&")
                
                textAttributes = [ NSFontAttributeName : smallFont , NSForegroundColorAttributeName : NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) ]
                
                textSize = text.sizeWithAttributes(textAttributes)
                
                textLocation = NSMakePoint(borderSize * 52.5 / 100.0 - textSize.width / 2.0, (1024.0 - textSize.height - borderSize * 62.5 / 100.0 + textSize.height / 2.0) / 2.0)
                
                text.drawAtPoint(textLocation, withAttributes: textAttributes)
                
                text = NSString(string: "F")
                
                textAttributes = [ NSFontAttributeName : bigFont , NSForegroundColorAttributeName : NSColor(red: 1.0, green: 80.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0) ]
                
                textSize = text.sizeWithAttributes(textAttributes)
                
                textLocation = NSMakePoint(borderSize * 77.5 / 100.0 - textSize.width / 2.0, (1024.0 - textSize.height - borderSize * 77.5 / 100.0 + textSize.height / 2.0) / 2.0)
                
                text.drawAtPoint(textLocation, withAttributes: textAttributes)
            }
        }

        if generate
        {
            performSelectorOnMainThread(#selector(AssetGeneratorView.generateImage), withObject: nil, waitUntilDone: false)
        }
        
        preview = false
    }
    
    func generateImage()
    {
        var borderSize : CGFloat
        
        if assetType == .Icon
        {
            borderSize = pointSize
        }
        else
        {
            borderSize = 1024.0 / pow(2, level)
        }
        
        if borderSize * NSScreen.mainScreen()!.backingScaleFactor < 1.0
        {
            return
        }

        var imageFrame = NSMakeRect(0.0, 1024.0 - borderSize, borderSize, borderSize)
        
        if assetType == .Icon
        {
            imageFrame.size.width /= NSScreen.mainScreen()!.backingScaleFactor
            imageFrame.size.height /= NSScreen.mainScreen()!.backingScaleFactor
            
            imageFrame.origin.y = 1024.0 - imageFrame.size.height
        }

        let bitmapImageRep = bitmapImageRepForCachingDisplayInRect(imageFrame)
        
        cacheDisplayInRect(imageFrame, toBitmapImageRep: bitmapImageRep!)

        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let documentsPath = paths[0]
        
        let pngData = bitmapImageRep!.representationUsingType(.NSPNGFileType, properties: [:])

        let imageName = "\(assetType)"
        
        let levelAsInt = Int(level)

        let imageDir = "\(documentsPath)/QuakeAssets/\(imageName)"
        
        var imagePath : String
        
        if assetType == .Icon
        {
            imagePath = "\(imageDir)/AppIcon_\(pointSize).png"
        }
        else if levelAsInt == 0
        {
            imagePath = "\(imageDir)/\(imageName).png"
        }
        else
        {
            imagePath = "\(imageDir)/\(imageName)_L\(levelAsInt).png"
        }
        
        do
        {
            try NSFileManager.defaultManager().createDirectoryAtPath(imageDir, withIntermediateDirectories: true, attributes: nil)
            
            pngData!.writeToFile(imagePath, atomically: false)
        }
        catch let error as NSError
        {
            NSLog("Could not create image \(imagePath), error \(error)")
        }
        
        if assetType == .Icon
        {
            pointSize = nextPointSize()
            
            if pointSize > 0.0
            {
                needsDisplay = true
            }
            else
            {
                generate = false
            }
        }
        else
        {
            let scaledBorderSize = NSScreen.mainScreen()!.backingScaleFactor * borderSize
            
            if scaledBorderSize > 1.0
            {
                level = level + 1.0
                
                needsDisplay = true
            }
            else
            {
                generate = false
            }
        }
    }
}
