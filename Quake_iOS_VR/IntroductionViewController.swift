//
//  IntroductionViewController.swift
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 7/8/16.
//
//

import UIKit
import GameController

class IntroductionViewController: UIViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var commandLabel: UILabel!
    
    var timer: NSTimer? = nil
    
    override func viewDidLoad()
    {
        titleLabel.text = "Welcome to Slip & Frag."
        
        descriptionLabel.text =
            "In order to play the game, you will need the following:\n\n" +
            " \u{2022} A Virtual Reality (VR) case based on the Google Cardboard design.\n" +
            " \u{2022} Data from the Shareware (or Registered) episodes of the game.\n" +
            " \u{2022} An iOS-compatible Extended Gaming Controller.\n\n" +
        "This guide will help you to quickly set up everything needed to play the game."
        
        checkControllerStatus()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(checkControllerStatus), userInfo: nil, repeats: true)
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

    func checkControllerStatus()
    {
        var command = "Tap on Next when you are ready."

        if remote != nil
        {
            command += "\n(Or press [A] to start playing.)"
        }

        commandLabel.text = command
    }

    @IBAction func onNext(sender: UIButton)
    {
        performSegueWithIdentifier("ToSetupData", sender: self)
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
