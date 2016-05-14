//
//  ViewController.swift
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/2/16.
//
//

import GLKit
import GameController

class ViewController: UIViewController, GCSCardboardViewDelegate
{
    @IBOutlet weak var cardboardView: GCSCardboardView!

    private var displayLink: CADisplayLink! = nil
    
    private var previousTime: NSTimeInterval = -1
    
    private var currentTime: NSTimeInterval = -1
    
    private var firstEyeRendered: Bool = false
    
    private var lastEyeRendered: Bool = false
    
    private var remote: GCController? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.cardboardView.delegate = self
        self.cardboardView.vrModeEnabled = true
        
        displayLink = CADisplayLink(target: self, selector: #selector(render))
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(controllerDidConnect), name: "GCControllerDidConnectNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(controllerDidDisconnect), name: "GCControllerDidDisconnectNotification", object: nil)
    }

    func render()
    {
        cardboardView.render()
    }

    func cardboardView(cardboardView: GCSCardboardView!, willStartDrawing headTransform: GCSHeadTransform!)
    {
        gl_screenwidth = Int32(cardboardView.bounds.width);
        gl_screenheight = Int32(cardboardView.bounds.height);

        Sys_Init(NSBundle.mainBundle().resourcePath!)
    }

    func cardboardView(cardboardView: GCSCardboardView!, prepareDrawFrame headTransform: GCSHeadTransform!)
    {
        if previousTime < 0
        {
            previousTime = NSProcessInfo().systemUptime
        }
        else if currentTime < 0
        {
            currentTime = NSProcessInfo().systemUptime
        }
        else
        {
            previousTime = currentTime
            
            currentTime = NSProcessInfo().systemUptime
            
            frame_lapse = Float(currentTime - previousTime)
        }
        
        firstEyeRendered = false
        lastEyeRendered = false
        
        Sys_FrameBeforeRender()
    }

    func cardboardView(cardboardView: GCSCardboardView!, drawEye eye: GCSEye, withHeadTransform headTransform: GCSHeadTransform!)
    {
        if firstEyeRendered
        {
            Sys_FrameRender()
            
            lastEyeRendered = true
            
            Sys_FrameAfterRender()
        }
        else if !lastEyeRendered
        {
            Sys_FrameRender()
            
            firstEyeRendered = true
        }
    }

    func cardboardView(cardboardView: GCSCardboardView!, didFireEvent event: GCSUserEvent)
    {
    }
    
    func cardboardView(cardboardView: GCSCardboardView!, shouldPauseDrawing pause: Bool)
    {
    }

    func controllerDidConnect(notification: NSNotification)
    {
        for controller in GCController.controllers()
        {
            if controller.extendedGamepad != nil && remote == nil
            {
                remote = controller
                
                remote!.playerIndex = .Index1

                remote!.extendedGamepad!.valueChangedHandler = { (gamepad: GCExtendedGamepad, element: GCControllerElement)->() in
                    
                }

                break
            }
        }
    }
    
    func controllerDidDisconnect(notification: NSNotification)
    {
        if remote != nil
        {
            remote!.playerIndex = .IndexUnset
            
            remote = nil
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

