//
//  SetupGameControllerViewController.swift
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 7/8/16.
//
//

import UIKit
import GameController

class SetupGameControllerViewController: UIViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var displayHelpLabel: UILabel!
    
    @IBOutlet weak var commandLabel: UILabel!
    
    var timer: Timer? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        titleLabel.text = "Step 2: Game Controller"
        
        descriptionLabel.text =
            "Now, ensure that your Extended Game Controller is correctly paired to this device. Once your " +
            "controller is paired, give it a few seconds and check that the Player 1 indicator LED is on.\n\n" +
            "To start playing, just press the [A] button in your controller.\n\n" +
        "To show this guide again, ensure that \"Display Help\" is checked in Settings."
        
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
        if remote != nil
        {
            commandLabel.text = "Game controller connected.\nPress [A] to start playing."
        }
        else
        {
            commandLabel.text = "Game controller not detected."
        }
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
