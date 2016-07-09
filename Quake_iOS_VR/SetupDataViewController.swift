//
//  SetupDataViewController.swift
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 7/8/16.
//
//

import UIKit
import GameController

class SetupDataViewController: UIViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var unpackButton: UIButton!
    
    @IBOutlet weak var commandLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    var timer: NSTimer? = nil
    
    override func viewDidLoad()
    {
        titleLabel.text = "Step 1: Game data"
        
        descriptionLabel.text =
            "The following choices are available:\n\n" +
            " \u{2022} Transfer a copy of the ID1/ directory from the game to this application, as well as any " +
            "other related files or directories, by using iTunes File Sharing.\n" +
            " \u{2022} Tap on \"Unpack Shareware Episode\" below.\n\n" +
            "The game can be found in Steam, or in online retail stores in CD format.\n\n" +
            "IMPORTANT: The filesystem in use for this device distinguishes between UPPERCASE and " +
            "lowercase file names. This engine expects lowercase file names - rename your files and " +
        "folders if needed."
        
        unpackButton.setTitle("Unpack Shareware Episode", forState: .Normal)

        checkGameData()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(checkGameData), userInfo: nil, repeats: true)
        
        self.view.setNeedsLayout()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        currentViewController = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(controllerDidConnect), name: "GCControllerDidConnectNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(controllerDidDisconnect), name: "GCControllerDidDisconnectNotification", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        currentViewController = nil
    }
    
    func checkGameData()
    {
        GameDataDetection.detect()

        var commandFirstLine = ""
        let commandSecondLine = "\nTap on Next when ready."
        var commandLastLine = "\n(Or press [A] to start playing.)"
        
        var hideNextButton = false
        
        if GameDataDetection.registeredPresent
        {
            if GameDataDetection.missionPack1Present && GameDataDetection.missionPack2Present
            {
                commandFirstLine = "Registered version with Mission Packs 1 & 2 detected. "
            }
            else if GameDataDetection.missionPack2Present
            {
                commandFirstLine = "Registered version with Mission Pack 2 detected. "
            }
            else if GameDataDetection.missionPack1Present
            {
                commandFirstLine = "Registered version with Mission Pack 1 detected. "
            }
            else
            {
                commandFirstLine = "Registered version detected. "
            }
        }
        else if GameDataDetection.sharewarePresent
        {
            commandFirstLine = "Shareware version detected. "
        }
        else
        {
            commandFirstLine = "No game data found."
            commandLastLine = "\n(Press [A] to start playing anyway.)"
            hideNextButton = true
        }
        
        if remote != nil && hideNextButton
        {
            commandLabel.text = commandFirstLine + commandLastLine
        }
        else if remote != nil
        {
            commandLabel.text = commandFirstLine + commandSecondLine + commandLastLine
        }
        else if hideNextButton
        {
            commandLabel.text = commandFirstLine
        }
        else
        {
            commandLabel.text = commandFirstLine + commandSecondLine
        }

        nextButton.hidden = hideNextButton
    }
    
    @IBAction func onUnpack(sender: UIButton)
    {
        let resourcesDir = NSBundle.mainBundle().resourcePath!
        
        let documentsDir = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true).path!
        
        let filename = "\(resourcesDir)/quake106data.zip";
        
        if NSFileManager.defaultManager().fileExistsAtPath(filename)
        {
            SSZipArchive.unzipFileAtPath(filename, toDestination: documentsDir)
        }
        
        checkGameData()
        
        unpackButton.setTitle("Shareware episode unpacked.", forState: .Disabled)
        unpackButton.enabled = false
    }
    
    @IBAction func onNext(sender: UIButton)
    {
        performSegueWithIdentifier("ToSetupGameController", sender: self)
    }
    
    func controllerDidConnect(notification: NSNotification)
    {
        GameControllerSetup.connect(notification.object as! GCController!)
    }
    
    func controllerDidDisconnect(notification: NSNotification)
    {
        GameControllerSetup.disconnect(notification.object as! GCController!)
    }
}
