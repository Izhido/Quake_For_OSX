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
    
    var timer: Timer? = nil
    
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
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkControllerStatus), userInfo: nil, repeats: true)
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        currentViewController = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDidConnect), name: NSNotification.Name(rawValue: "GCControllerDidConnectNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDidDisconnect), name: NSNotification.Name(rawValue: "GCControllerDidDisconnectNotification"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        currentViewController = nil
    }

    @objc func checkControllerStatus()
    {
        var command = "Tap on Next when you are ready."

        if remote != nil
        {
            command += "\n(Or press [A] to start playing.)"
        }

        commandLabel.text = command
    }

    @IBAction func onNext(_ sender: UIButton)
    {
        performSegue(withIdentifier: "ToSetupData", sender: self)
    }
    
    @objc func controllerDidConnect(_ notification: Notification)
    {
        GameControllerSetup.connect(notification.object as? GCController)
    }
    
    @objc func controllerDidDisconnect(_ notification: Notification)
    {
        GameControllerSetup.disconnect(notification.object as? GCController)
    }
}
